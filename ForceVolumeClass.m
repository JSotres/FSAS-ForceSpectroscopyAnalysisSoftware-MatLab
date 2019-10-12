classdef ForceVolumeClass < handle
    % Class definition of Force Volume Objects
    %   Detailed explanation goes here
    
    properties (Access = public)
        % General Properties
        Ramp; % Force distance ramp
        %MapRepresentation;  % handle to the map/image on to which actions will apply
        NumberOfMapRows;    % Number of rows in the FV file
        NumberOfMapColumns; % Number of columns in the FV file
        MapLength           % Lateral dimension of the probed area 
        
    end
    
    methods (Access = public)
        function fv = ForceVolumeClass(FileName, FilePath, creationMethod)
            % Construct an instance of this class
            switch creationMethod
                case 1
                % This indicates that the object corresponds to a force
                % volume file, and it is created by calling the function
                % LoadNanoScope5ForceVolumeFiles
                    [fv.Ramp, fv.NumberOfMapRows, ...
                        fv.NumberOfMapColumns, fv.MapLength] =...
                        LoadNanoScope5ForceVolumeFiles(FileName, FilePath);
                case 2                    
                % This indicates that the object corresponds to a list of
                % force distance ramps, and it is created by calling the 
                % function
                % LoadForceRamps
                    fv.Ramp = LoadForceRamps(FileName, FilePath);
                    if iscell(FileName)
                        fv.NumberOfMapRows = size(FileName, 2);
                    else
                        fv.NumberOfMapRows = 1;
                    end
                    fv.NumberOfMapColumns = 1;                
            end
        end
        
        function YOffsetAverage(fv, Selection, AnalysisParameters)
            [row, col, ~] = find(Selection);
            for i = 1:length(row)
                fv.Ramp{row(i),col(i)}.YOffsetAverageRamp(AnalysisParameters);
            end
        end
        
        function RampCalibration(fv, Selection, AnalysisParameters)
            [row, col, ~] = find(Selection);
            for i = 1:length(row)
                fv.Ramp{row(i),col(i)}.RampCalibration(AnalysisParameters);
            end
        end
        
        function HertzXOffset(fv, Selection, AnalysisParameters)
            [row, col, ~] = find(Selection);
            h = waitbar(0,'Calculating Hertz Fits');
            for i = 1:length(row)
                fv.Ramp{row(i),col(i)}.HertzXOffsetRamp(AnalysisParameters);             
                waitbar(i/length(row), h);
            end
            close(h);
        end
        
        function ProbeSampleDistanceConverter(fv, Selection, AnalysisParameters)
            [row, col, ~] = find(Selection);
            for i = 1:length(row)
                fv.Ramp{row(i),col(i)}.ProbeSampleDistanceConverter(AnalysisParameters);
            end
        end
        
        function ExponentialFit(fv, Selection, AnalysisParameters)
            [row, col, ~] = find(Selection);
            h = waitbar(0,'Calculating Exponential Fits');
            for i = 1:length(row)
                if ~isnan(fv.Ramp{row(i),col(i)}.Property(6))
                	fv.Ramp{row(i),col(i)}.ExponentialFitRamp(AnalysisParameters);
                end
                waitbar(i/length(row), h);
            end
            close(h);
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

