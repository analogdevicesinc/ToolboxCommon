classdef (Abstract) DeviceAttribute < adi.common.RegisterReadWrite & adi.common.DebugAttribute
    % DeviceAttribute IIO device attribute function calls
    
    methods (Hidden)
        function cnt = iio_context_get_devices_count(obj, ctxPtr)
        % iio_context_get_devices_count(const struct iio_context * 	ctx)
        %
        % Enumerate the devices found in the given context.
            if useCalllib(obj)
                cnt = calllib(obj.libName, 'iio_context_get_devices_count', ctxPtr);
            end
        end
        
        function devPtr = iio_context_get_device(obj, ctxPtr, index)
        % iio_context_get_device(const struct iio_context * ctx, unsigned int index)
        %
        % Get the device present at the given index.
            if useCalllib(obj)
                devPtr = calllib(obj.libName, 'iio_context_get_device', ctxPtr, index);
                status = cPtrCheck(obj,devPtr);
                if status ~= 0
                    releaseImpl(obj);
                    error("Failed to find device with index: %s",index);
                end
            end
        end
        
        function cnt = iio_device_get_attrs_count(obj, devPtr)
        % iio_device_get_attrs_count(const struct iio_device *dev)
        %
        % Enumerate the devices found in the given context.
            if useCalllib(obj)
                cnt = calllib(obj.libName, 'iio_device_get_attrs_count', devPtr);
            end
        end
        
        function name = iio_device_get_name(obj, devPtr)
        % iio_device_get_name(const struct iio_device *dev)
        %
        % Get the name of the given device
            if useCalllib(obj)
                name = calllib(obj.libName, 'iio_device_get_name', devPtr);
            end
        end
               
        function attr = iio_device_get_attr(obj, devPtr, index)
            % iio_device_get_attr(const struct iio_device *dev, unsigned int index)
            %
            % Get the value of the given channel-specific attribute.
            if useCalllib(obj)
                attr = calllib(obj.libName, 'iio_device_get_attr', devPtr, index);
            end
        end
        
    end
end
