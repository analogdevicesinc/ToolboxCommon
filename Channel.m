classdef (Abstract) Channel < adi.common.RegisterReadWrite & adi.common.DebugAttribute
    % DeviceAttribute IIO device attribute function calls
    
    methods (Hidden)
        function cnt = iio_channel_get_attrs_count(~, chanPtr)
        % iio_channel_get_attrs_count(const struct iio_channel * chanPtr)
        %
        % Enumerate the channel found in the given device.
            cnt = numel(chanPtr.attrs);
        end
        
        function name = iio_channel_get_name(~, chanPtr)
        % iio_channel_get_name(const struct iio_channel *chn)
        %
        % Get the name of the given channel
            name = chanPtr.name;
        end
        
        function id = iio_channel_get_id(~, chanPtr)
        % iio_channel_get_id(const struct iio_channel *chn)
        %
        % Get the id of the given channel
            id = chanPtr.id;
        end
        
        function attr = iio_channel_get_attr(~, chanPtr, indx)
        % iio_channel_get_attr(const struct iio_channel *chn, indx)
        %
        % Get the attr of the given channel by index
            % indx counts from 0. The result is the name of the
            % attribute, as with libiio v0.
            attrs = chanPtr.attrs;
            attr = attrs(indx+1).name;
        end
        
        
        
        
    end
    
end