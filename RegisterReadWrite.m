classdef (Abstract) RegisterReadWrite < matlabshared.libiio.base 
    
    methods (Hidden)
        
        function setRegister(obj, value, addr, phydev)
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
            [status, value] = iio_device_reg_read(obj,phydev,addr_dec);
            cstatus(obj,status,['Error reading address: ' addr]);            
        end
        
        function setRegisterExtended(obj, value, addr, mask_bin, bit_shift, phydev)
            if (nargin < 6)
                phydev = getDev(obj, obj.phyDevName);
            end
            if (nargin == 5)
                value = value*2^(bit_shift);
            end
            addr_dec = hex2dec(addr);
            mask_dec = bin2dec(mask_bin);
            [status, curr_val] = iio_device_reg_read(obj,phydev,addr_dec);
            cstatus(obj,status,['Error reading address: ' addr]);
            new_val = bitxor(value, bitand(bitxor(value, curr_val), mask_dec));            
            status = iio_device_reg_write(obj,phydev,addr_dec,new_val);
            cstatus(obj,status,['Address write failed for : ' addr ' with value ' num2str(value)]);        
        end
        
        function value = getRegisterExtended(obj, addr, mask_bin, bit_shift, phydev)
            if (nargin < 5)
                phydev = getDev(obj, obj.phyDevName);
            end
            addr_dec = hex2dec(addr);
            [status, value] = iio_device_reg_read(obj,phydev,addr_dec);
            if (nargin >= 3)
                mask_dec = 255-bin2dec(mask_bin);
                value = bitand(value, mask_dec);            
                if (nargin == 4)
                    value = value/2^(bit_shift);
                end
            end
            cstatus(obj,status,['Error reading address: ' addr]);            
        end
    end        
end