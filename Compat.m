classdef (Abstract) Compat < adi.common.BufferADI & ...
        adi.libiio.base & matlabshared.libiio.base
    properties(Hidden, Access = private)
        major
        minor
        gitTag        
    end

    properties (Abstract)
        LibIIOVersion
    end

    methods (Hidden, Access = protected)
        
        function stepImpl(obj)
        end
    
        function obj = setupImpl(obj)
        end

        function releaseImpl(obj)
            if strcmpi(obj.LibIIOVersion,'1.0')
                releaseImpl@adi.libiio.base(obj);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                releaseImpl@matlabshared.libiio.base(obj);
            end
        end
    end

    methods(Hidden, Access = {?handle})
        function [major, minor, gitTag] = iio_library_get_version(obj)
            if strcmpi(obj.LibIIOVersion,'1.0')
                [major, minor, gitTag] = iio_library_get_version@adi.libiio.base(obj);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                [major, minor, gitTag] = iio_library_get_version@matlabshared.libiio.base(obj);
            end
        end

        function phydev = getDev(obj, phyDevName)
            if strcmpi(obj.LibIIOVersion,'1.0')
                phydev = getDev@adi.libiio.base(obj, phyDevName);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                phydev = getDev@matlabshared.libiio.base(obj, phyDevName);
            end
        end

        % need to flip the order of output arguments in other places for
        % consistency
        function [devPtr, status] = iio_context_find_device(obj, ctxPtr, name)
            if strcmpi(obj.LibIIOVersion,'1.0')
                devPtr = adi.libiio.context.iio_context_find_device(ctxPtr, name);
                status = -int32(isNull(devPtr));
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                % wrapper doesn't exist
                [status, devPtr] = iio_context_find_device@matlabshared.libiio.base(obj, ctxPtr, name);
            end
        end

        function chanPtr = iio_device_find_channel(obj,phydev,id,isOutput)
            if strcmpi(obj.LibIIOVersion,'1.0')
                chanPtr = adi.libiio.device.iio_device_find_channel(phydev,id,isOutput);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                chanPtr = iio_device_find_channel@matlabshared.libiio.device(obj,phydev,id,isOutput);
            end
        end

        function status = iio_channel_attr_write_longlong(obj,chanPtr,attr,value)
            if strcmpi(obj.LibIIOVersion,'1.0')
                status = adi.libiio.channel.iio_channel_attr_write_longlong(chanPtr,attr,value);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                status = iio_channel_attr_write_longlong@matlabshared.libiio.channel(obj,chanPtr,attr,value);
            end
        end

        function [status, rValue] = iio_channel_attr_read_longlong(obj,chanPtr,attr)
            if strcmpi(obj.LibIIOVersion,'1.0')
                [status, rValue] = adi.libiio.channel.iio_channel_attr_read_longlong(chanPtr,attr);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                [status, rValue] = iio_channel_attr_read_longlong@matlabshared.libiio.channel(obj);
            end
        end

        function status = iio_channel_attr_write_bool(obj,chanPtr,attr,value)
            if strcmpi(obj.LibIIOVersion,'1.0')
                status = adi.libiio.channel.iio_channel_attr_write_bool(chanPtr,attr,value);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                status = iio_channel_attr_write_bool@matlabshared.libiio.channel(obj,chanPtr,attr,value);
            end
        end

        function [status, value] = iio_channel_attr_read_bool(obj,chanPtr,attr)
            if strcmpi(obj.LibIIOVersion,'1.0')
                [status, value] = adi.libiio.channel.iio_channel_attr_read_bool(chanPtr,attr);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                [status, value] = iio_channel_attr_read_bool@matlabshared.libiio.channel(obj,chanPtr,attr);
            end
        end

        function nBytes = iio_channel_attr_write(obj, chanPtr, attr, src)
            if strcmpi(obj.LibIIOVersion,'1.0')
                nBytes = adi.libiio.channel.iio_channel_attr_write(chanPtr, attr, src);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                nBytes = iio_channel_attr_write@matlabshared.libiio.channel(obj, chanPtr, attr, src);
            end
        end

        function nBytes = iio_device_attr_write(obj, devPtr, attr, src)
            if strcmpi(obj.LibIIOVersion,'1.0')
                nBytes = adi.libiio.device.iio_device_attr_write(devPtr, attr, src);
            elseif strcmpi(obj.LibIIOVersion,'0.25')
                nBytes = iio_device_attr_write@matlabshared.libiio.device(obj, devPtr, attr, src);
            end
        end
    end
end