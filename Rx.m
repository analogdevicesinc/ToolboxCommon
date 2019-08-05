classdef (Abstract) Rx  < adi.common.RxTx & matlab.system.mixin.SampleTime ...
         & adi.common.BufferADI
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
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SamplesPerFrame/obj.SamplingRate);
        end
        
    end
    
    methods (Access=protected)
        
        function numOut = getNumOutputsImpl(~)
            numOut = 2;
        end
        
        function names = getOutputNamesImpl(~)
            % Return output port names for System block
            names = {'data','valid'};
        end
        
        function sizes = getOutputSizeImpl(obj)
            % Return size for each output port
            sizes = {[obj.SamplesPerFrame,obj.channelCount],[1,1]};
        end
        
        function types = getOutputDataTypeImpl(~)
            % Return data type for each output port
            types = ["int16","logical"];
        end
        
        function complexities = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            complexities = {obj.ComplexData,false};
        end
        
        function fixed = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            fixed = {true,true};
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
            
            % Get the data            
            if obj.ComplexData
                kd = 1;
                ce = length(obj.EnabledChannels);
                [dataRAW, valid] = getData(obj);
                data = complex(zeros(obj.SamplesPerFrame,ce));
                for k = 1:ce
                    data(:,k) = complex(dataRAW(kd,:),dataRAW(kd+1,:)).';
                    kd = kd + 2;
                end
            else
                if obj.BufferTypeConversionEnable
                    [dataRAW, valid] = getData(obj);
                    % Channels must be in columns or pointer math fails
                    dataRAW = dataRAW.';
                    [D1, D2] = size(dataRAW);
                    data = coder.nullcopy(zeros(D1, D2, obj.dataTypeStr));
                    dataPtr = libpointer(obj.ptrTypeStr,data);
                    dataRAWPtr = libpointer(obj.ptrTypeStr,dataRAW);
                    % Convert hardware format to human format channel by
                    % channel
                    for l = 0:D2-1
                        chanPtr = getChan(obj, obj.iioDev, obj.channel_names{l+1}, false);
                        % Pull out column
                        tmpPtrSrc = dataRAWPtr + D1*l;
                        tmpPtrDst = dataPtr + D1*l;
                        setdatatype(tmpPtrSrc,obj.ptrTypeStr, D1, 1);
                        setdatatype(tmpPtrDst,obj.ptrTypeStr, D1, 1);
                        for k=0:D1-1
                            iio_channel_convert(obj,chanPtr,tmpPtrDst+k,tmpPtrSrc+k);
                        end
                    end
                    data = dataPtr.Value;
                else
                    [data, valid] = getData(obj);
                    data = data.';
                end
            end
            
        end
        
    end
    
end

