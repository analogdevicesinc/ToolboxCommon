classdef (Abstract) Compat < matlabshared.libiio.base & ...
        adi.common.BufferADI & adi.libiio.base
    properties
        major
        minor
        gitTag
    end

    methods(Hidden, Access = {?handle})
        function getDev(obj)
            if isprop(obj,'libraryVersion')
                phydev = getDev@matlabshared.libiio.base(obj, obj.phyDevName);
            elseif isprop(obj,'libraryVersion_v1')
                % this is a stub call
                % input and output arguments might be different in V1.0
                phydev = getDev@matlabshared.libiio.base_v1p0(obj, obj.phyDevName);
            end
        end

        function chanPtr = iio_device_find_channel(obj,phydev,id,isOutput)
            if isprop(obj,'libraryVersion')
                chanPtr = iio_device_find_channel@matlabshared.libiio.device(obj,phydev,id,isOutput);%FIXME (INVERSION)
            elseif isprop(obj,'libraryVersion_v1')
                % this is a stub call
                % input and output arguments might be different in V1.0
                chanPtr = iio_device_find_channel@matlabshared.libiio.device_v1p0(obj,phydev,id,isOutput);%FIXME (INVERSION)
            end
        end

        function status = iio_channel_attr_write_longlong(obj,chanPtr,attr,value)
            if isprop(obj,'libraryVersion')
                status = iio_channel_attr_write_longlong@matlabshared.libiio.channel(obj,chanPtr,attr,value);
            elseif isprop(obj,'libraryVersion_v1')
                % this is a stub call
                % input and output arguments might be different in V1.0
                % status = iio_channel_attr_write_longlong@matlabshared.libiio.channel_v1p0(obj,chanPtr,attr,value);
                status = obj.iio_channel_attr();
            end
        end

        function [status, rValue] = iio_channel_attr_read_longlong(obj,chanPtr,attr)
            if isprop(obj,'libraryVersion')
                [status, rValue] = iio_channel_attr_read_longlong@matlabshared.libiio.channel(obj,chanPtr,attr);
            elseif isprop(obj,'libraryVersion_v1')
                % this is a stub call
                % input and output arguments might be different in V1.0
                [status, rValue] = iio_channel_attr_read_longlong@matlabshared.libiio.channel_v1p0(obj);
            end
        end

        function iio_channel_convert(obj, chanPtr, dst, src)
            if isprop(obj,'libraryVersion')
                iio_channel_convert@adi.common.BufferADI(obj, chanPtr, dst, src)
            elseif isprop(obj,'libraryVersion_v1')
                iio_channel_convert@adi.libiio.low_level(obj, chanPtr, dst, src)
            end
        end
    end
end