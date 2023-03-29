classdef (Abstract) Attribute < adi.common.RegisterReadWrite & ...
        adi.common.DebugAttribute & adi.common.DeviceAttribute
    % Attribute IIO attribute function calls
    
    methods (Hidden)
        
        function setAttributeLongLong(obj,id,attr,value,isOutput,tol,phydev,readAttrWritten)
            if nargin < 8
                readAttrWritten = true;
            end
            if nargin < 7
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            status = iio_channel_attr_write_longlong(obj,chanPtr,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' num2str(value)]);
            % Check
            if readAttrWritten
                [status, rValue] = iio_channel_attr_read_longlong(obj,chanPtr,attr);
                cstatus(obj,status,['Error reading attribute: ' attr]);
                if ~exist('tol') || ~isa(tol,'double')
                    tol = double(sqrt(eps));
                end
                if abs(value - rValue) > tol
                    status = -1;
                    cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
                end
            end
        end
        
        function setAttributeDouble(obj,id,attr,value,isOutput,tol,phydev,readAttrWritten)
            if nargin < 8
                readAttrWritten = true;
            end
            if nargin < 7
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            status = iio_channel_attr_write_double(obj,chanPtr,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' num2str(value)]);
            % Check
            if readAttrWritten
                [status, rValue] = iio_channel_attr_read_double(obj,chanPtr,attr);
                cstatus(obj,status,['Error reading attribute: ' attr]);
                if ~exist('tol') || ~isa(tol,'double')
                    tol = double(sqrt(eps));
                end
                if abs(value - rValue) > tol
                    status = -1;
                    cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
                end
            end
        end
        
        function rValue = getAttributeLongLong(obj,id,attr,isOutput,phydev)
            if nargin < 5
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [status, rValue] = iio_channel_attr_read_longlong(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end

        function rValue = getAttributeDouble(obj,id,attr,isOutput,phydev)
            if nargin < 5
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [status, rValue] = iio_channel_attr_read_double(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end

        
        function setAttributeBool(obj,id,attr,value,isOutput,phydev,readAttrWritten)
            if nargin < 7
                readAttrWritten = true;
            end
            if nargin < 6
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            status = iio_channel_attr_write_bool(obj,chanPtr,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr]);
            % Check
            if readAttrWritten
                [status, rValue] = iio_channel_attr_read_bool(obj,chanPtr,attr);
                cstatus(obj,status,['Error reading attribute: ' attr]);
                if value ~= rValue
                    status = -1;
                    cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
                end
            end
        end
        
        function rValue = getAttributeBool(obj,id,attr,isOutput,phydev)
            if nargin < 5
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [status, rValue] = iio_channel_attr_read_bool(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end
        
        function setAttributeRAW(obj,id,attr,value,isOutput,phydev,readAttrWritten)
            if nargin < 7
                readAttrWritten = true;
            end
            if nargin < 6
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            bytes = iio_channel_attr_write(obj,chanPtr,attr,value);
            if bytes <= 0
                if readAttrWritten
                    status = -1;
                    cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' value]);
                end
            end
        end
        
        function rValue = getAttributeRAW(obj,id,attr,isOutput,phydev)
            if nargin < 5
                phydev = getDev(obj, obj.phyDevName);
            end
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [bytes, rValue] = iio_channel_attr_read(obj,chanPtr,attr,1024);
            if bytes <= 0
                status = -1;
                cstatus(obj,status,['Attribute read failed for : ' attr]);
            end
        end
        
        function setDeviceAttributeRAW(obj,attr,value,phydev,readAttrWritten)
            if nargin < 5
                readAttrWritten = true;
            end
            if nargin < 4
                phydev = getDev(obj, obj.phyDevName);
            end
            bytes = iio_device_attr_write(obj,phydev,attr,value);
            if bytes <= 0
                if readAttrWritten
                    status = -1;
                    cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' value]);
                end
            end
        end
        
        function setDeviceAttributeLongLong(obj,attr,value,phydev,readAttrWritten)
            if nargin < 5
                readAttrWritten = true;
            end
            if nargin < 4
                phydev = getDev(obj, obj.phyDevName);
            end
            iio_device_attr_write_longlong(obj,phydev,attr,value);
            % Check
            [status, rValue] = iio_device_attr_read_longlong(obj,phydev,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
            if value ~= rValue
                if readAttrWritten
                    status = -1;
                    cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
                end
            end
        end
        
        function rValue = getDeviceAttributeLongLong(obj,attr,phydev)
            if nargin < 3
                phydev = getDev(obj, obj.phyDevName);
            end
            % Check
            [status, rValue] = iio_device_attr_read_longlong(obj,phydev,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end
        
        function rValue = getDeviceAttributeRAW(obj,attr,len,phydev)
            if nargin < 4
                phydev = getDev(obj, obj.phyDevName);
            end
            [status, rValue] = iio_device_attr_read(obj,phydev,attr,len);
            if status == 0
                cstatus(obj,-1,['Error reading attribute: ' attr]);
            end
        end
        
    end
end
