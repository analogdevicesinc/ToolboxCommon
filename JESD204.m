classdef JESD204 < adi.common.Attribute
    %JESD204 Helper Functions
    methods
        function out = CheckStatus(obj)
            statusString = obj.getDebugAttributeRAW('status');
            ss = strsplit(statusString,'\n');
            out = struct;
            out.rx = [];
            out.tx = [];
            for l = 1:length(ss)
                str = ss{l};
                if contains(str,'JRX')
                    out.tx = str;
                elseif contains(str,'JTX')
                    out.rx = str;
                end
            end
            %
            out.ctrl = obj.getDeviceAttributeRAW('jesd204_fsm_ctrl',128);
            out.error = obj.getDeviceAttributeRAW('jesd204_fsm_error',128);
            out.paused = obj.getDeviceAttributeRAW('jesd204_fsm_paused',128);
            out.state = obj.getDeviceAttributeRAW('jesd204_fsm_state',128);
        end
    end
end