classdef (Abstract) Sensor  < adi.common.RxTx & adi.common.Attribute
    % Sensor: Common shared functions between sensor classes
    properties (Nontunable, Hidden)
        %SamplesPerFrame Samples Per Frame
        %   Number of samples per frame, specified as an even positive
        %   integer from 2 to 16,777,216.
        SamplesPerFrame = 1024;
    end

    properties (Nontunable)
       %ReadMode Read Mode
       %    Specify whether to return the latest or the oldest data
       %    samples. The number of samples depends on the SamplesPerRead
       %    value. The data read from the sensor is stored in the MATLAB
       %    buffer.
       ReadMode = 'oldest';
       %   Set the output format of the data returned by executing the read
       %   function. When the OutputFormat is set to timetable, the data
       %   returned has the following fields (if supported by device):
       %       Time — Time stamps in datetime or duration format
       %       Acceleration — N-by-3 array in units of m/s^2
       %       AngularVelocity — N-by-3 array in units of rad/s
       %       MagneticField — N-by-3 array in units of µT (microtesla)
       %   When the OutputFormat is set to matrix, the data is returned as
       %   matrices of acceleration, angular velocity, magnetic field, and
       %   time stamps. The units for the sensor readings are the same as
       %   the timetable format. The size of each matrix is N-by-3. N is
       %   the number of samples per read specified by SamplesPerRead. The
       %   three columns of each field represent the measurements in x, y,
       %   and z axes.
       OutputFormat = 'matrix';
    end
    
    properties (Nontunable)
        %SamplesPerRead Samples Per Read
        %   Number of samples per read, specified as a positive
        %   integer.
        SamplesPerRead
    end
    
    methods
        function value = get.SamplesPerRead(obj)
            value = obj.SamplesPerFrame;
        end
        function set.SamplesPerRead(obj,value)
            obj.SamplesPerFrame = value; %#ok<MCSUP> 
        end
    end
    
    properties(Constant, Hidden)
        ReadModeSet = matlab.system.StringSet({ ...
            'oldest','latest'});
        OutputFormatSet = matlab.system.StringSet({ ...
            'timetable','matrix'});
    end
    
    methods (Abstract)
        read(obj);
        flush(obj);
    end
        
    methods (Hidden, Access = protected)
       
        function flag = isInactivePropertyImpl(obj, prop)
            flag = isInactivePropertyImpl@adi.common.RxTx(obj, prop);
            flag = flag || strcmpi(prop,'EnabledChannels');
            flag = flag || strcmpi(prop,'SamplesPerFrame');
            % NOT SUPPORTED YET
            flag = flag || strcmpi(prop,'OutputFormat');
        end 
    end
    
end

