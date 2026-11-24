classdef (Abstract) Tx  < adi.common.RxTx & adi.common.DDS
    % Tx: Common shared functions between transmitter classes
    
    methods (Hidden, Access = protected)
        
        function numIn = getNumInputsImpl(obj)
            if strcmp(obj.DataSource,'DDS')
                numIn = 0;
            else
                numIn = 1;
            end
        end
        
    end
    
    methods (Hidden, Access = protected)

        function setupImpl(obj,data)
            if strcmp(obj.DataSource,'DMA')
                obj.SamplesPerFrame = size(data,1);
            end
            % Call the superclass method
            setupImpl@adi.common.RxTx(obj);
        end
        
        function [dataType, isComplex, raw] = getStreamFormat(obj)
            % Format of a transmitted frame: one column per channel
            % (per I/Q pair for complex devices), the values are the
            % storage words. They are rounded to the nearest integer
            % and saturate at the limits of the storage word of the
            % channel, whatever its width: no cast to int16 or to
            % dataTypeStr is made here.
            dataType = obj.dataTypeStr;
            isComplex = obj.ComplexData;
            raw = true;
        end
        
        function valid = stepImpl(obj,dataIn)
            % valid = tx(data) returns a logical value that indicates
            % data was sent to the device correctly.
            %
            % When 'DataSource' is 'DMA' the input 'data' will be an [NxM]
            % vector where N is the length of the input data and M is the
            % number of elements in 'EnabledChannels'. 'data' should be
            % complex if the device assumes complex data.
            % 
            % When 'DataSource' is 'DDS' the operator will take no inputs.
            % Running the operator simply will for a DDS settings update
            % and connect to the device if never run before.
            
            if strcmp(obj.DataSource,'DMA')
                c = obj.channelCount;
                s = size(dataIn);
                if obj.ComplexData
                    assert(s(2)==c/2,sprintf('Data size must [Nx%d]\n',c/2));
                else
                    assert(s(2)==c,sprintf('Data size must [Nx%d]\n',c));
                end
                % The stream converts, interleaves and queues the frame
                valid = writeFrame(obj,dataIn);
            else
                valid = true;
                obj.DDSUpdate();
            end            
        end
        
    end
    
end

