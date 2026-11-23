classdef (Abstract) DeviceAttribute < adi.common.RegisterReadWrite & adi.common.DebugAttribute
    % DeviceAttribute IIO device attribute function calls
    
    methods (Hidden)
        function cnt = iio_context_get_devices_count(~, ctxPtr)
        % iio_context_get_devices_count(const struct iio_context * 	ctx)
        %
        % Enumerate the devices found in the given context.
            cnt = numel(ctxPtr.devices);
        end
        
        function devPtr = iio_context_get_device(obj, ctxPtr, index)
        % iio_context_get_device(const struct iio_context * ctx, unsigned int index)
        %
        % Get the device present at the given index.
        % index counts from 0. The result is an iio.Device.
            devs = ctxPtr.devices;
            if index < 0 || index >= numel(devs)
                releaseImpl(obj);
                error("Failed to find device with index: %d",index);
            end
            devPtr = devs(index+1);
        end
        
        function cnt = iio_device_get_attrs_count(~, devPtr)
        % iio_device_get_attrs_count(const struct iio_device *dev)
        %
        % Enumerate the devices found in the given context.
            cnt = numel(devPtr.attrs);
        end
        
        function name = iio_device_get_name(~, devPtr)
        % iio_device_get_name(const struct iio_device *dev)
        %
        % Get the name of the given device
            name = devPtr.name;
        end
               
        function attr = iio_device_get_attr(~, devPtr, index)
            % iio_device_get_attr(const struct iio_device *dev, unsigned int index)
            %
            % Get the value of the given channel-specific attribute.
            % index counts from 0. The result is the name of the
            % attribute, as with libiio v0.
            attrs = devPtr.attrs;
            attr = attrs(index+1).name;
        end
        
    end
end
