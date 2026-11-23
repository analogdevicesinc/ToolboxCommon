classdef (Abstract) IIOBase < matlab.System
    % IIOBase Base System object on the libiio v1 MATLAB bindings
    %   Replaces matlabshared.libiio.base (libiio v0 through calllib) for
    %   the device classes of the ADI toolboxes. It keeps the member names
    %   those classes call (getDev, getChan, cstatus, the iio_* wrappers
    %   with their status return values, createBuf/destroyBuf, ...), and
    %   implements them with the package "iio" (iio.Context, iio.Device,
    %   iio.Attr, iio.RxStream, iio.TxStream).
    %
    %   Pointers of the v0 API become iio objects: a "device pointer" is
    %   an iio.Device, a "channel pointer" an iio.Channel, and a pointer
    %   that was NULL is an empty array.
    %
    %   The data path is one iio.RxStream or iio.TxStream per object. The
    %   stream converts a whole frame in one call, so no sample is touched
    %   in MATLAB code.
    %
    %   Not supported by this base: code generation, Simulink and HDL
    %   targeting (the bindings call a MEX file), calllib access to the
    %   library (libName, useCalllib, useCodegen) and the old getData and
    %   sendData (use readFrame and writeFrame).
    %
    %   See also iio.Context, iio.RxStream, iio.TxStream

    properties
        %uri URI
        %   Address of the IIO context, for example 'ip:192.168.2.1',
        %   'ip:pluto.local' or 'local:'
        uri = 'ip:192.168.2.1';
    end

    properties (Nontunable, Logical)
        %enIO Enable I/O
        %   Kept for compatibility with matlabshared.libiio.base. Not used.
        enIO = true;
    end

    properties (Abstract, Hidden, Access = protected)
        %isOutput True for a transmitter, false for a receiver
        isOutput
    end

    properties (Hidden, Access = protected)
        %iioCtx iio.Context, [] while not connected
        iioCtx = [];
        %iioDev iio.Device that streams (devName), [] while not connected
        iioDev = [];
        %iioBuf iio.RxStream or iio.TxStream, [] while there is none
        iioBuf = [];
        %needsTeardown True from the moment the context exists
        needsTeardown = false;
        %bufIsCyclic True: the first transmitted frame repeats
        bufIsCyclic = false;
        %pIsInSimulink Always false with this base
        pIsInSimulink = false;
    end

    properties (Hidden, Access = private)
        %streamChannels Channel ids in column order (I then Q when complex)
        streamChannels = {};
        %lastIIOError What failed last in an iio_* wrapper, and the message
        %   of the bindings: 'write of frequency: ...'. cstatus and cerrmsg
        %   add it to their error. A write starts again without it, and so
        %   does a lookup that finds nothing: both are a new operation,
        %   and what failed before them (and was ignored) is not its cause.
        lastIIOError = '';
    end

    methods
        %% Constructor
        function obj = IIOBase(varargin)
            coder.allowpcode('plain');
            setProperties(obj, nargin, varargin{:});
        end
    end

    %% System object flow
    methods (Hidden, Access = protected)

        function setupImpl(obj)
            % Context, streaming device, then what the subclass defines in
            % configureChanBuffers: attributes, channels and the stream
            try
                setupLib(obj);
                initPointers(obj);
                getContext(obj);
                setContextTimeout(obj);
                obj.iioDev = getDev(obj, obj.devName);
                status = configureChanBuffers(obj);
            catch err
                teardownContext(obj);
                rethrow(err);
            end
            cstatus(obj, status, ['Failed to configure: ' obj.devName]);
        end

        function releaseImpl(obj)
            teardownContext(obj);
        end

        function [dataType, isComplex, raw] = getStreamFormat(obj)
            % Options of the stream that createBuf opens. Rx and Tx
            % override this.
            %   dataType   class of a received frame
            %   isComplex  true: the channels are I then Q of each column
            %   raw        true: the storage words as they are
            dataType = obj.dataTypeStr;
            isComplex = false;
            raw = true;
        end

        function [data, valid] = readFrame(obj)
            % One received frame: SamplesPerFrame rows, one column per
            % channel (per I/Q pair when complex). valid is false, and
            % data all zero, when no frame arrived in time.
            if isempty(obj.iioBuf)
                error('adi:iio:notConnected', ...
                    'No open buffer for %s: the device was released.', obj.devName);
            end
            [data, valid] = obj.iioBuf.read();
        end

        function valid = writeFrame(obj, data)
            % Queue one frame for transmission: at most SamplesPerFrame
            % rows, one column per channel (per I/Q pair when complex)
            if isempty(obj.iioBuf)
                error('adi:iio:notConnected', ...
                    'No open buffer for %s: the device was released.', obj.devName);
            end
            valid = obj.iioBuf.write(data);
        end

    end

    %% Members of matlabshared.libiio.base that the device classes call
    methods (Hidden)

        function tf = isInSimulink(~)
            % Simulink is not supported by this base
            tf = false;
        end

        function setupLib(~)
            % Nothing to load: the bindings are a MEX file
        end

        function teardownLib(~)
        end

        function initPointers(obj)
            obj.iioCtx = [];
            obj.iioDev = [];
            obj.iioBuf = [];
            obj.streamChannels = {};
            obj.lastIIOError = '';
        end

        function getContext(obj)
            % Create the context of obj.uri
            obj.iioCtx = iio.Context(obj.uri);
            obj.needsTeardown = true;
        end

        function setContextTimeout(obj)
            % A finite, positive Timeout (seconds) becomes the timeout of
            % the context. Inf, 0 or no Timeout property keep the default
            % of the backend.
            if isprop(obj, 'Timeout')
                t = obj.Timeout;
                if isnumeric(t) && isscalar(t) && isfinite(t) && t > 0
                    obj.iioCtx.set_timeout(round(1000 * double(t)));
                end
            end
        end

        function setupDataType(~, dataTypeStr)
            % Check the data type of the buffer
            validatestring(dataTypeStr, {'int8', 'uint8', 'int16', 'uint16', ...
                'int32', 'uint32', 'int64', 'uint64', 'single', 'double'}, ...
                '', 'dataTypeStr');
        end

        function dev = getDev(obj, name)
            % iio.Device with the given name; an error if there is none
            if isempty(obj.iioCtx)
                error('adi:iio:notConnected', ...
                    'Not connected: the device %s is available after setup.', name);
            end
            dev = obj.iioCtx.find_device(name);
            status = cPtrCheck(obj, dev);
            cstatus(obj, status, ['Failed to find device: ' name]);
        end

        function chanPtr = getChan(obj, dev, name, isOutput)
            % iio.Channel of a device; an error if there is none
            chanPtr = iio_device_find_channel(obj, dev, name, isOutput);
            status = cPtrCheck(obj, chanPtr);
            cstatus(obj, status, ['Failed to find channel: ' name]);
        end

        function status = cPtrCheck(obj, ptr)
            % 0 for an object, -ENODEV for an empty result
            if isempty(ptr)
                % a lookup that finds nothing is not caused by an earlier
                % failure of the bindings
                obj.lastIIOError = '';
                status = -19;
            else
                status = 0;
            end
        end

        function cstatus(obj, status, msg)
            % A negative status releases the hardware and is an error
            if status < 0
                detail = obj.lastIIOError;
                obj.lastIIOError = '';
                releaseImpl(obj);
                if isempty(detail)
                    error('adi:iio:status', '%s (status %d)', msg, status);
                else
                    error('adi:iio:status', '%s (status %d; last libiio error, %s)', msg, status, detail);
                end
            end
        end

        function cerrmsg(obj, status, msg)
            % Error with the text of a status; releases the hardware
            detail = obj.lastIIOError;
            obj.lastIIOError = '';
            releaseImpl(obj);
            if isempty(detail)
                error('adi:iio:status', '%s (status %d: %s)', msg, status, iio.strerror(abs(status)));
            else
                error('adi:iio:status', '%s (status %d; last libiio error, %s)', msg, status, detail);
            end
        end

        %% Channels and the buffer
        function enableChannel(obj, ~, name, ~)
            % Add a channel of the streaming device to the stream that
            % createBuf opens. The order of the calls is the column order.
            if ~any(strcmp(obj.streamChannels, name))
                obj.streamChannels{end + 1} = name;
            end
        end

        function disableChannel(obj, ~, name, ~)
            obj.streamChannels(strcmp(obj.streamChannels, name)) = [];
        end

        function status = createBuf(obj)
            % Open the stream for the channels enabled so far. A
            % transmitter whose DataSource is 'DDS' gets none.
            status = 0;
            if obj.isOutput && isprop(obj, 'DataSource') && strcmp(obj.DataSource, 'DDS')
                return
            end
            [dataType, isComplex, raw] = getStreamFormat(obj);
            % DataTimeout (seconds) is the Timeout of the stream (ms). A
            % finite, positive value makes the stream wait with
            % non-blocking dequeues 1 ms apart (libiio-conv,
            % iio_conv_stream_set_timeout); RxTx sets 5, so that is the
            % default. 0 and Inf give -1: one blocking dequeue, bounded
            % by the timeout of the context. matlabshared.libiio.base
            % documented 0 as non-blocking or the context default and Inf
            % as infinite; Inf is not infinite here.
            timeout = -1;
            if isprop(obj, 'DataTimeout')
                t = obj.DataTimeout;
                if isnumeric(t) && isscalar(t) && isfinite(t) && t > 0
                    timeout = round(1000 * double(t));
                end
            end
            numBlocks = max(1, double(obj.kernelBuffersCount));
            try
                if obj.isOutput
                    obj.iioBuf = iio.TxStream(obj.iioDev, obj.streamChannels, ...
                        SamplesPerFrame = double(obj.SamplesPerFrame), ...
                        Complex = isComplex, Raw = raw, ...
                        NumBlocks = numBlocks, Timeout = timeout, ...
                        Cyclic = logical(obj.bufIsCyclic));
                else
                    obj.iioBuf = iio.RxStream(obj.iioDev, obj.streamChannels, ...
                        SamplesPerFrame = double(obj.SamplesPerFrame), ...
                        OutputDataType = dataType, ...
                        Complex = isComplex, Raw = raw, ...
                        NumBlocks = numBlocks, Timeout = timeout);
                end
            catch err
                status = iioFail(obj, err, ['opening the buffer of ' obj.devName]);
            end
        end

        function destroyBuf(obj)
            % Close the stream. A transmitter first sends what is queued.
            if ~isempty(obj.iioBuf)
                buf = obj.iioBuf;
                obj.iioBuf = [];
                buf.close();
            end
        end

        %% Lookup
        function devPtr = iio_context_find_device(~, ctxPtr, name)
            if isempty(ctxPtr)
                devPtr = [];
            else
                devPtr = ctxPtr.find_device(name);
            end
        end

        function chanPtr = iio_device_find_channel(~, devPtr, id, isOutput)
            if isempty(devPtr)
                chanPtr = [];
            else
                chanPtr = devPtr.find_channel(id, logical(isOutput));
            end
        end

        %% Channel attributes
        function [bytes, value] = iio_channel_attr_read(obj, chanPtr, attr, ~)
            [bytes, value] = attrRead(obj, chanPtr, attr, 'channel', 'string');
        end

        function [status, value] = iio_channel_attr_read_bool(obj, chanPtr, attr)
            [status, value] = attrRead(obj, chanPtr, attr, 'channel', 'bool');
        end

        function [status, value] = iio_channel_attr_read_longlong(obj, chanPtr, attr)
            [status, value] = attrRead(obj, chanPtr, attr, 'channel', 'longlong');
        end

        function [status, value] = iio_channel_attr_read_double(obj, chanPtr, attr)
            [status, value] = attrRead(obj, chanPtr, attr, 'channel', 'double');
        end

        function bytes = iio_channel_attr_write(obj, chanPtr, attr, value)
            bytes = attrWrite(obj, chanPtr, attr, 'channel', 'string', value);
        end

        function status = iio_channel_attr_write_bool(obj, chanPtr, attr, value)
            status = attrWrite(obj, chanPtr, attr, 'channel', 'bool', value);
        end

        function status = iio_channel_attr_write_longlong(obj, chanPtr, attr, value)
            status = attrWrite(obj, chanPtr, attr, 'channel', 'longlong', value);
        end

        function status = iio_channel_attr_write_double(obj, chanPtr, attr, value)
            status = attrWrite(obj, chanPtr, attr, 'channel', 'double', value);
        end

        %% Device attributes
        function [bytes, value] = iio_device_attr_read(obj, devPtr, attr, ~)
            [bytes, value] = attrRead(obj, devPtr, attr, 'device', 'string');
        end

        function [status, value] = iio_device_attr_read_bool(obj, devPtr, attr)
            [status, value] = attrRead(obj, devPtr, attr, 'device', 'bool');
        end

        function [status, value] = iio_device_attr_read_longlong(obj, devPtr, attr)
            [status, value] = attrRead(obj, devPtr, attr, 'device', 'longlong');
        end

        function [status, value] = iio_device_attr_read_double(obj, devPtr, attr)
            [status, value] = attrRead(obj, devPtr, attr, 'device', 'double');
        end

        function bytes = iio_device_attr_write(obj, devPtr, attr, value)
            bytes = attrWrite(obj, devPtr, attr, 'device', 'string', value);
        end

        function status = iio_device_attr_write_bool(obj, devPtr, attr, value)
            status = attrWrite(obj, devPtr, attr, 'device', 'bool', value);
        end

        function status = iio_device_attr_write_longlong(obj, devPtr, attr, value)
            status = attrWrite(obj, devPtr, attr, 'device', 'longlong', value);
        end

        function status = iio_device_attr_write_double(obj, devPtr, attr, value)
            status = attrWrite(obj, devPtr, attr, 'device', 'double', value);
        end

        %% Debug attributes
        function [bytes, value] = iio_device_debug_attr_read(obj, devPtr, attr, ~)
            [bytes, value] = attrRead(obj, devPtr, attr, 'debug', 'string');
        end

        function [status, value] = iio_device_debug_attr_read_bool(obj, devPtr, attr)
            [status, value] = attrRead(obj, devPtr, attr, 'debug', 'bool');
        end

        function [status, value] = iio_device_debug_attr_read_longlong(obj, devPtr, attr)
            [status, value] = attrRead(obj, devPtr, attr, 'debug', 'longlong');
        end

        function [status, value] = iio_device_debug_attr_read_double(obj, devPtr, attr)
            [status, value] = attrRead(obj, devPtr, attr, 'debug', 'double');
        end

        function bytes = iio_device_debug_attr_write(obj, devPtr, attr, value)
            bytes = attrWrite(obj, devPtr, attr, 'debug', 'string', value);
        end

        function status = iio_device_debug_attr_write_bool(obj, devPtr, attr, value)
            status = attrWrite(obj, devPtr, attr, 'debug', 'bool', value);
        end

        function status = iio_device_debug_attr_write_longlong(obj, devPtr, attr, value)
            status = attrWrite(obj, devPtr, attr, 'debug', 'longlong', value);
        end

        function status = iio_device_debug_attr_write_double(obj, devPtr, attr, value)
            status = attrWrite(obj, devPtr, attr, 'debug', 'double', value);
        end

        %% Registers
        function [status, value] = iio_device_reg_read(obj, devPtr, addr)
            status = 0;
            value = uint32(0);
            if isempty(devPtr)
                status = -19;
                return
            end
            try
                value = devPtr.reg_read(addr);
            catch err
                status = iioFail(obj, err, 'register read');
            end
        end

        function status = iio_device_reg_write(obj, devPtr, addr, value)
            status = 0;
            obj.lastIIOError = '';
            if isempty(devPtr)
                status = -19;
                return
            end
            try
                devPtr.reg_write(addr, value);
            catch err
                status = iioFail(obj, err, 'register write');
            end
        end

    end

    %% Internal
    methods (Access = private)

        function teardownContext(obj)
            % Close the stream, then destroy the context. Harmless when
            % repeated, and on an object that was never set up.
            if obj.needsTeardown
                obj.needsTeardown = false;
                try
                    % defined by adi.common.RxTx; a class without it has
                    % nothing more to release than the stream below
                    releaseChanBuffers(obj);
                catch err
                    if ~strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                        warning('adi:iio:release', ...
                            'Releasing the buffer of %s failed: %s', obj.devName, err.message);
                    end
                end
                destroyBuf(obj);
                if ~isempty(obj.iioCtx)
                    delete(obj.iioCtx);
                end
                teardownLib(obj);
            end
            obj.iioCtx = [];
            obj.iioDev = [];
            obj.streamChannels = {};
        end

        function status = iioFail(obj, err, what)
            % Negative errno of an error of the bindings ("iio:<ERRNO>").
            % Any other error is not caught. WHAT names the operation
            % ('write of frequency'); it is kept with the message.
            if ~strncmp(err.identifier, 'iio:', 4)
                rethrow(err);
            end
            obj.lastIIOError = [what ': ' err.message];
            status = -adi.common.IIOBase.errnoOf(err.identifier(5:end));
        end

        function [status, value] = attrRead(obj, parent, name, kind, type)
            % status: 0, or for type 'string' the number of bytes read
            % (the text and its terminator); negative errno on failure
            switch type
                case 'bool'
                    value = false;
                case 'longlong'
                    value = int64(0);
                case 'double'
                    value = 0;
                otherwise
                    value = '';
            end
            [a, status] = adi.common.IIOBase.findAttr(parent, name, kind);
            if status < 0
                obj.lastIIOError = '';
                return
            end
            try
                switch type
                    case 'bool'
                        value = a.read_bool();
                    case 'longlong'
                        value = a.read_longlong();
                    case 'double'
                        value = a.read_double();
                    otherwise
                        value = a.read();
                        status = numel(value) + 1;
                end
            catch err
                status = iioFail(obj, err, ['read of ' name]);
            end
        end

        function status = attrWrite(obj, parent, name, kind, type, value)
            % status: 0, or for type 'string' the number of bytes written
            % (the text and its terminator); negative errno on failure
            obj.lastIIOError = '';
            [a, status] = adi.common.IIOBase.findAttr(parent, name, kind);
            if status < 0
                return
            end
            try
                switch type
                    case 'bool'
                        a.write_bool(logical(value));
                    case 'longlong'
                        a.write_longlong(int64(value));
                    case 'double'
                        % six decimals, as libiio v0 wrote a double
                        a.write_double(double(value), Exact = false);
                    otherwise
                        text = char(value);
                        a.write_string(text);
                        status = numel(text) + 1;
                end
            catch err
                status = iioFail(obj, err, ['write of ' name]);
            end
        end

    end

    methods (Static, Access = private)

        function [a, status] = findAttr(parent, name, kind)
            % iio.Attr of a channel ('channel'), of a device ('device') or
            % a debug attribute of a device ('debug')
            a = [];
            if isempty(parent)
                status = -19;   % ENODEV: no such channel or device
                return
            end
            if strcmp(kind, 'debug')
                a = parent.find_debug_attr(name);
            else
                a = parent.find_attr(name);
            end
            if isempty(a)
                status = -2;    % ENOENT: no such attribute
            else
                status = 0;
            end
        end

        function n = errnoOf(name)
            % Number of an errno name of the bindings; 1 when unknown
            names = {'EPERM', 'ENOENT', 'EIO', 'EBADF', 'EAGAIN', 'ENOMEM', ...
                'EACCES', 'EBUSY', 'ENODEV', 'EINVAL', 'ENOSYS', 'EPIPE', ...
                'ENOTSUP', 'ETIMEDOUT', 'EFBIG'};
            numbers = [1, 2, 5, 9, 11, 12, 13, 16, 19, 22, 38, 32, 95, 110, 27];
            k = find(strcmp(names, name), 1);
            if ~isempty(k)
                n = numbers(k);
            else
                n = sscanf(name, 'E%d');
                if ~isscalar(n) || n <= 0
                    n = 1;
                end
            end
        end

    end

end
