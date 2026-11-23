classdef (Abstract) BufferADI < adi.common.IIOBase
    % BufferADI IIO buffer management function calls
    %   Kept so that classes that list it as a superclass still load. The
    %   conversion from hardware format to host format is done by the
    %   stream of adi.common.IIOBase (BufferTypeConversionEnable of
    %   adi.common.Rx), a whole frame in one call.

    methods (Hidden)
        function iio_channel_convert(~, ~, ~, ~)
        % iio_channel_convert (struct iio_channel *chn, void * dst, const void* src)
        %
        % Not available with the libiio v1 bindings: there are no sample
        % pointers in MATLAB.
            error('adi:iio:notSupported', ...
                ['iio_channel_convert on sample pointers is not available with the ', ...
                'libiio v1 bindings. Set BufferTypeConversionEnable instead.']);
        end
    end
end
