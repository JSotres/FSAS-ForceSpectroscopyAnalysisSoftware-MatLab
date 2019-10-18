classdef ForceVolumeClass < handle
    % Class definition of Force Volume Objects
    
    properties (Access = public)
        % Force distance ramp
        Ramp
        % Number of rows in the FV file
        NumberOfMapRows
        % Number of columns in the FV file
        NumberOfMapColumns
        % Lateral dimension of the probed area
        MapLength            
        
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
                        LoadNanoScopeForceVolumeFiles(FileName, FilePath);
                case 2                    
                % This indicates that the object corresponds to a list of
                % force distance ramps, and it is created by calling the 
                % function LoadForceRamps
                    fv.Ramp = LoadForceRamps(FileName, FilePath);
                    % Identification of the number of Ramps, number
                    % assigned to NumberOfMapRows in order to keep the same
                    % nomenclature as in the case of analysis of force
                    % volume files
                    if iscell(FileName)
                        % If several files are loaded
                        fv.NumberOfMapRows = size(FileName, 2);
                    else
                        % If only one file is loaded
                        fv.NumberOfMapRows = 1;
                    end
                    % The nuber of columns in a set of Ramps will always be
                    % 1
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
        
        function LinearFit(fv, Selection, AnalysisParameters, xRepresentation, yRepresentation)
            [row, col, ~] = find(Selection);
            h = waitbar(0,'Calculating Linear Fits');
            for i = 1:length(row)
                fv.Ramp{row(i),col(i)}.LinearFitRamp(AnalysisParameters, xRepresentation, yRepresentation);
                waitbar(i/length(row), h);
            end
            close(h);
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
    end
end

