classdef (Abstract) DebugAttribute < matlabshared.libiio.base 
    
    methods (Hidden)
        function setDebugAttributeLongLong(obj,attr,value,skipCheck,phydev)
            if nargin < 4
                phydev = getDev(obj, obj.phyDevName);
                skipCheck = false;
            end
            if nargin < 5
                phydev = getDev(obj, obj.phyDevName);
            end
            if (nargin == 1)
                iio_device_debug_attr_write_longlong(obj,phydev, 'initialize',1);
                return;
            end
            status = iio_device_debug_attr_write_longlong(obj,phydev,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' num2str(value)]);
            % Check
            if ~skipCheck
                [status, rValue] = iio_device_debug_attr_read_longlong(obj,phydev,attr);
                cstatus(obj,status,['Error reading attribute: ' attr]);
                if (value ~= rValue)
                    status = -1;
                    cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
                end
            end
        end

        function rValue = getDebugAttributeLongLong(obj,attr)
            phydev = getDev(obj, obj.phyDevName);
            [status, rValue] = iio_device_debug_attr_read_longlong(obj,phydev,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end
        
        function setDebugAttributeBool(obj,attr,value,skipCheck,phydev)
            if nargin < 4
                phydev = getDev(obj, obj.phyDevName);
                skipCheck = false;
            end
            if nargin < 5
                phydev = getDev(obj, obj.phyDevName);
            end
            if (nargin == 1)
                iio_device_debug_attr_write_bool(obj,phydev, 'initialize',1);
                return;
            end
            status = iio_device_debug_attr_write_bool(obj,phydev,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr]);
            % Check (Not implemented yet)
%             [status, rValue] = iio_device_debug_attr_read_bool(obj,phydev,attr);
%             cstatus(obj,status,['Error reading attribute: ' attr]);
%             if value ~= rValue
%                 status = -1;
%                 cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
%             end            
        end                
    end       
end