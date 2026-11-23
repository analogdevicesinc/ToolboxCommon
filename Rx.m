classdef (Abstract) Rx  < adi.common.RxTx & adi.common.BufferADI
    % Rx: Common shared functions between receiver classes
    properties(Constant, Hidden, Logical)
        %EnableCyclicBuffers Enable Cyclic Buffers
        %   Not used for RX
        EnableCyclicBuffers = false;
    end
    
    properties(Hidden, Logical, Nontunable)
        %BufferTypeConversionEnable Buffer Type Conversion Enable
        %   Utilize iio_channel_convert on each sample. If unnecessary
        %   there is a large performance penalty.
        BufferTypeConversionEnable = false;
    end
    
    methods (Hidden, Access = protected)
        
        function sts = getSampleTimeImpl(obj)
            if isa(obj.SampleRate,'char')
                sts = createSampleTime(obj,'Type','Discrete',...
                    'SampleTime',obj.SamplesPerFrame/str2double(obj.SampleRate));
            else
                sts = createSampleTime(obj,'Type','Discrete',...
                    'SampleTime',obj.SamplesPerFrame/obj.SampleRate);
            end
        end
        
    end
    
    methods (Access=protected)
        
        function numOut = getNumOutputsImpl(~)
            numOut = 2;
        end
        
        function varargout = getOutputNamesImpl(~)
            % Return output port names for System block
            varargout = {'data','valid'};
        end
        
        function varargout = getOutputSizeImpl(obj)
            % Return size for each output port
            varargout = {[obj.SamplesPerFrame,obj.channelCount],[1,1]};
        end
        
        function varargout = getOutputDataTypeImpl(~)
            % Return data type for each output port
            varargout = {"int16","logical"}; %#ok<CLARRSTR>
        end
        
        function varargout = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            varargout = {obj.ComplexData,false};
        end
        
        function varargout = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            varargout = {true,true};
        end
    end
    
    methods (Hidden, Access = protected)
        
        function [data,valid] = stepImpl(obj)
            % [data,valid] = rx() returns data received from the radio
            % hardware associated with the receiver System object, rx.
            % The output 'valid' indicates whether the object has received 
            % data from the radio hardware. The first valid data frame can
            % contain transient values, resulting in packets containing 
            % undefined data.
            %
            % The output 'data' will be an [NxM] vector where N is
            % 'SamplesPerFrame' and M is the number of elements in
            % 'EnabledChannels'. 'data' will be complex if the devices
            % assumes complex data operations.
            
            % The frame arrives converted and in its final shape from
            % the stream (see getStreamFormat)
            [data, valid] = readFrame(obj);
            
        end
        
        function [dataType, isComplex, raw] = getStreamFormat(obj)
            % Format of a received frame, as the M-code data path of
            % this class delivered it:
            % - complex devices: double, complex, one column per I/Q
            %   pair, holding the storage words as they are
            % - other devices: class dataTypeStr, one column per
            %   channel, the storage words as they are, or the samples
            %   in host format (shifted, masked, sign extended) with
            %   BufferTypeConversionEnable
            isComplex = obj.ComplexData;
            if isComplex
                dataType = 'double';
                raw = true;
            else
                dataType = obj.dataTypeStr;
                raw = ~obj.BufferTypeConversionEnable;
            end
        end
        
    end
    
end

