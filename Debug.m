classdef (Abstract) Debug < matlabshared.libiio.base
    % DeviceAttribute IIO device attribute function calls
    
    methods (Hidden)
        
        function [nBytes, value] = iio_device_debug_attr_read(obj, devPtr, attr, len)
        % iio_device_debug_attr_read(const struct iio_device *dev, const char *attr)
        %
        % Read the content of the given debug attribute. 
            if useCalllib(obj)
                dstPtr = libpointer('cstring',repmat(' ',1,len+1));
                [nBytes, ~, ~, value] = calllib(obj.libName, 'iio_device_debug_attr_read', devPtr, attr, dstPtr, uint32(len));
            end
        end        
        
    end
    
end