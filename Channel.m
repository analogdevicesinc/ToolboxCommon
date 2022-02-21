classdef (Abstract) Channel < adi.common.RegisterReadWrite & adi.common.DebugAttribute
    % DeviceAttribute IIO device attribute function calls
    
    methods (Hidden)
        function cnt = iio_channel_get_attrs_count(obj, chanPtr)
        % iio_channel_get_attrs_count(const struct iio_channel * chanPtr)
        %
        % Enumerate the channel found in the given device.
            if useCalllib(obj)
                cnt = calllib(obj.libName, 'iio_channel_get_attrs_count', chanPtr);
            end
        end
        
        function name = iio_channel_get_name(obj, chanPtr)
        % iio_channel_get_name(const struct iio_channel *chn)
        %
        % Get the name of the given channel
            if useCalllib(obj)
                name = calllib(obj.libName, 'iio_channel_get_name', chanPtr);
            end
        end
        
        function id = iio_channel_get_id(obj, chanPtr)
        % iio_channel_get_id(const struct iio_channel *chn)
        %
        % Get the id of the given channel
            if useCalllib(obj)
                id = calllib(obj.libName, 'iio_channel_get_id', chanPtr);
            end
        end
        
        function attr = iio_channel_get_attr(obj, chanPtr, indx)
        % iio_channel_get_attr(const struct iio_channel *chn, indx)
        %
        % Get the attr of the given channel by index
            if useCalllib(obj)
                attr = calllib(obj.libName, 'iio_channel_get_attr', chanPtr,indx);
            end
        end
        
        
        
        
    end
    
end