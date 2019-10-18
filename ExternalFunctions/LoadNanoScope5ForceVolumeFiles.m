function [Ramp, NumberOfMapRows,...
    NumberOfMapColumns, MapLength] = ...
    LoadNanoScope5ForceVolumeFiles(FileName, FilePath)
% LoadNanoScope5ForceVolumeFiles.m: Reads Nanoscope 5 force volume files. 
% 
% Input parametrs:
%   - FileNames -> Name of the force volume file to be read.
%   - FilePath -> Path where the file to be read is.
%
% Output parameters:
%   - Ramp -> cell array with {number_of_rows, number_of_columns} dimensions
%             where each member is an object of ForceRamp class.
%   - NumberOfMapRows -> number of rows of the force volume measurement.
%   - NumberOfMapColumns -> number of columns of the force volume
%                           measurement.
%   - MapLength -> lateral scan size of the force volume measurement.
%
% Based on the scripts developed by Jaco de Groot,available at: 
% https://se.mathworks.com/matlabcentral/fileexchange/11515-open-nanoscope-6-afm-images
%
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

%--------------------------------------------------------------------------
% Add and move to the input file path route
addpath(FilePath);
cd(FilePath);

%--------------------------------------------------------------------------
% Definition of the strings with relevant information to be searched in the
% header of the force volume file. 
searchstring(1).label='@Sens. Zsens:';
searchstring(2).label='@2:Z scale:';
searchstring(3).label='Samps/line:';
searchstring(4).label='Data offset';
searchstring(5).label='Scan Size:';
searchstring(6).label='@Z magnify:';
searchstring(7).label='\@4:Ramp size:';
searchstring(8).label='\Force Data Points:';
searchstring(9).label='\Number of lines:';

%--------------------------------------------------------------------------
%Reads from the force volume file the values corresponding to the search
% strings specified above
param = ReadHeaderValues(FileName,searchstring);

%--------------------------------------------------------------------------
% Assign read parameters to variables for easy code reading
NumberOfMapRows = param(9).values(2);
NumberOfMapColumns = param(3).values(7);
MapLength = param(5).values(1);
RampLength=param(7).values(1)*param(1).values(1);
NumberOfRampPoints = param(3).values(2);
ScanIncrement = RampLength/(NumberOfRampPoints-1);

%--------------------------------------------------------------------------
% Creates two variables accounting for the two laterla dimensions of each
% point of the force volume file
PixelLengthColumn = MapLength/NumberOfMapRows;
PixelLengthRow = MapLength/NumberOfMapColumns;

%--------------------------------------------------------------------------
% Opens the file and goes to the position where the topography map is    
fid = fopen(FileName,'r');
fseek(fid,param(4).values(1),-1);
% Loads the topography map in a 2d array
topography =...
    (param(1).values(1) * param(2).values(1) *...
    fread(fid, [param(3).values(1) param(3).values(1)],'int16'))/(65535+1);
% Flip the topography map 90 degrees
topography =...
    flipdim(rot90(topography,3),2);

%--------------------------------------------------------------------------
% Opens the file and goes to the position where the binary data of
% the Force Volume map is and loads it into the "FZS" variable
fseek(fid,param(4).values(2),-1);
FZS = fread(fid,...
    [2*NumberOfRampPoints NumberOfMapRows*NumberOfMapColumns],...
    'int16');
% Initializes a counter indicating the number of force distance curves
counter = 0;
% Loads each of the force diatance ramps contained in FZS in the
% ForceRamp objects Ramp{NXPixel,NYPixel}
for NXPixel=1:NumberOfMapRows
    for NYPixel=1:NumberOfMapColumns
        % Each fz ramp is declared as an instance of the class
        % ForceRampClass
        Ramp{NXPixel,NYPixel} = ForceRampClass;
        % Counter is incremented
        counter=counter + 1;
        % Creates two properites of the object Ramp, corresponding to its
        % x and y lateral positions
        Ramp{NXPixel,NYPixel}.Property(1) = (NXPixel-1)*PixelLengthColumn;
        Ramp{NXPixel,NYPixel}.Property(2) = (NYPixel-1)*PixelLengthRow;
        % Assigns the 2d array "topography" to the property "height" of the
        % object "Ramp"
        Ramp{NXPixel,NYPixel}.Property(3) = topography(NXPixel,NYPixel);
        % The sample vertical position values of the forward and backward
        % ramps (XF and XB) are created from the known values of the length
        % of the ramp and the distance between vertical positions
        Ramp{NXPixel,NYPixel}.XF(1:NumberOfRampPoints,1) =...
            0:ScanIncrement:RampLength;
        Ramp{NXPixel,NYPixel}.XB(1:NumberOfRampPoints,1) =...
            0:ScanIncrement:RampLength;
        % The photodetector vertical signals are read from the FZS
        % variable. Note that they are scaled by the factor 0.000375, which
        % corresponds to the LSB scale parameter of Force Volume Files
        Ramp{NXPixel,NYPixel}.YF(:,1) =...
            FZS(1:NumberOfRampPoints,counter)*0.000375;
        % Sometime, the photodetector vertical signals of the forward ramp
        % have significantly unreal low values. Here, if they are below
        % -10, the value is assigned a NaN value
        for h=1:length(Ramp{NXPixel,NYPixel}.YF(:,1))
            if Ramp{NXPixel,NYPixel}.YF(h,1)<-10
                Ramp{NXPixel,NYPixel}.YF(h,1) = NaN;
            end
        end
        Ramp{NXPixel,NYPixel}.YB(:,1) =...
            FZS(NumberOfRampPoints+1:2*NumberOfRampPoints,counter)...
            *0.000375;
        % Declaration of the properties "FZRepresentationX" and
        % "FZRepresentationY", representing whether the corresponding
        % representation has been defined (with a 1) or not (with a 0).
        % First, the 1st instanceof these two properties, corresponding to
        % the raw data, are initialized with a 1
        % Then, we assign a 0 to the others, which have not yet been
        % defined. Specifically, they correspond to:
        % FZRepresentationX(2) -> offset corrected
        % FZRepresentationX(3) -> probe-sample distance
        % FZRepresentationY(2) -> offset corrected
        % FZRepresentationY(3) -> deflection
        % FZRepresentationY(4) -> force
        Ramp{NXPixel,NYPixel}.FZRepresentationX = [1 0 0];
        Ramp{NXPixel,NYPixel}.FZRepresentationY = [1 0 0 0];
        % A similar notation is used to determine if different
        % fits/analysis have been applied to the ramps.
        % AnalysisRepresentation(1) -> Hertz Fit
        % AnalysisRepresentation(2) -> Linear fit
        % AnalysisRepresentation(3) -> Exponential Fit
        Ramp{NXPixel,NYPixel}.AnalysisRepresentation = [0 0 0];
        % Initializes propertie of the object Ramp "selected", which 
        % defines whether analysis procedures will be applied to the
        % ramp (1) or not (0)
        Ramp{NXPixel,NYPixel}.Property(4) = 1;
        % From fits/analysis of fz ramps, parameters will be obtained,
        % These will be stored both (for convinience) as properties of the
        % ramp object and as properties MapRepresentation(x).PixelValue,
        % of the force volume object.
        %
        % For slope fitting:
        Ramp{NXPixel,NYPixel}.Property(5) = NaN;
        % For Hertz fitting:    
        Ramp{NXPixel,NYPixel}.Property(6) = NaN;
        Ramp{NXPixel,NYPixel}.Property(7) = NaN;
        % For adhesion analysis:
        % (Maximum Adhesion)
        Ramp{NXPixel,NYPixel}.Property(8) = NaN;
        % (Adhesion Work)
        Ramp{NXPixel,NYPixel}.Property(9) = NaN;
        % For fitting to exponential function:
        % (Exponential Amplitude)        
        Ramp{NXPixel,NYPixel}.Property(10) = NaN;        
        % (Exponential Length) 
        Ramp{NXPixel,NYPixel}.Property(11) = NaN;
        %
        % For linear fitting: this fit is supported in all X and Y
        % representations, but only for one representation at a time. The
        % properties linearFitRepresentationX and linearFitRepresentationY
        % identify the representations for which the linear fit applies
        Ramp{NXPixel,NYPixel}.linearFitRepresentationX = NaN;
        Ramp{NXPixel,NYPixel}.linearFitRepresentationY = NaN;
    end
end

%Close the file
fclose('all');

