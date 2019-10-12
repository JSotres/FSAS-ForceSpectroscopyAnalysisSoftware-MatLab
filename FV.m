classdef ForceVolumeClass
    % Class definition of Force Volume Objects
    %   Detailed explanation goes here
    
    properties
        % General Properties
        Scan; % Force distance curve
        MapRepresentation;  % handle to the map/image on to which actions will apply
        NumberOfOriginalScans;  % Total number of scans
        NumberOfRampPoints; % Points for each scan
        NumberOfMapRows;    % Number of rows in the FV file
        NumberOfMapColumns; % Number of columns in the FV file
        ScanIncrement;  % Distance ramped between points in force scans
        MapLength;
        PixelLength;    % Lateral distance bewteen positions where force scans were performed
        NumberOfImagePoints;
        ScanLength;
        PhotodetectorSensitivity; % Sensitivity of the photdetector in nm/V
        SpringConstant; % Force constant of the cantilever in nN/nm
    end
    
    methods
        function obj = ForceVolumeClass
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj = LoadNanoScope5ForceVolumeFiles;
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

