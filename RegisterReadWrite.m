classdef (Abstract) RegisterReadWrite < matlabshared.libiio.base 
    
    methods (Hidden)
        function setRegister(obj, addr, value, phydev)
            if nargin < 4
                phydev = getDev(obj, obj.phyDevName);
            end
            addr_dec = hex2dec(addr);
            status = iio_device_reg_write(obj,phydev,addr_dec,value);
            cstatus(obj,status,['Address write failed for : ' addr ' with value ' num2str(value)]);
        end
        
        function value = getRegister(obj, addr, phydev)
            if nargin < 3
                phydev = getDev(obj, obj.phyDevName);
            end
            addr_dec = hex2dec(addr);
            % Check
            [status, value] = iio_device_reg_read(obj,phydev,addr_dec);
            cstatus(obj,status,['Error reading address: ' addr]);            
        end
    end        
end
