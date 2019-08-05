classdef (Abstract) BufferADI < matlabshared.libiio.base 
    % BufferADI IIO buffer management function calls
   
    methods (Hidden)
        function iio_channel_convert(obj, chanPtr, dst, src)
        % iio_channel_convert (struct iio_channel *chn, void * dst, const void* src)
        %
        % Convert the sample from hardware format to host format.
            if useCalllib(obj)
                calllib(obj.libName, 'iio_channel_convert', chanPtr, dst, src);
            elseif useCodegen(obj)
                coder.ceval('iio_channel_convert', chanPtr, dst, src);
            end
        end
    end
end

