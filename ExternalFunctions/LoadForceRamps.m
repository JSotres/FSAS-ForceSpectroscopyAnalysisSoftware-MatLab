function Ramp = LoadForceRamps(FileNames, FilePath)
% LoadForceRamps.m: Reads Nanoscope 5 force volume files.
%
% Input parameters:
%   - FileNames -> Name of the files to be read.
%   - FilePath -> Path where the files to be read are.
%
% Output parameter:
%   - Ramp -> cell array with {number_of_files, 1} dimensions where each
%   member is an object of ForceRamp class.
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

% Retrieve the number of loaded force ramps
if iscell(FileNames)
    % in the case that NumberOfFiles is a cell array i.e., several
    % files/ramps are to be loaded
    NumberOfFiles = size(FileNames, 2);
else
    % in the case NumberOfFiles is a string i.e., just one file/ramp is to
    % be loaded
    NumberOfFiles = 1;
end
%--------------------------------------------------------------------------

% Loads each of the force diatance ramps contained in FZS in the
% ForceRamp objects Ramp{number_of_ramps,1}
for i=1:NumberOfFiles
    % Each fz ramp is declared as an instance of the class ForceRampClass
    Ramp{i, 1} = ForceRampClass;
    
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
    Ramp{i, 1}.FZRepresentationX = [1 0 0];
    Ramp{i, 1}.FZRepresentationY = [1 0 0 0];
    
    % A similar notation is used to determine if different
	% fits/analysis have been applied to the ramps.
	% AnalysisRepresentation(1) -> Hertz Fit
	% AnalysisRepresentation(2) -> Linear fit
	% AnalysisRepresentation(3) -> Exponential Fit
    Ramp{i, 1}.AnalysisRepresentation = [0 0 0];
    
    % Assign the "sample vertical position" values of the ramp (in both 
    % the forward and backward directions) to the properties of the 
    % ForceRamp object Ramp{i, 1}.X(F/B), and the corresponding 
    % photodetector values to the properties object Ramp{i, 1}.Y(F/B).
    % For this, the external function OpenForceRampMultimode.m is called
    if NumberOfFiles > 1
        % in the case several files/ramps are to be read
        [Ramp{i, 1}.XF Ramp{i, 1}.YF Ramp{i, 1}.XB Ramp{i, 1}.YB] =...
            OpenForceRampMultimode(FileNames{i});
        Ramp{i, 1}.Title = FileNames{i};
    elseif NumberOfFiles == 1
        % in the case only one file/ramp is to be read
        [Ramp{i, 1}.XF Ramp{i, 1}.YF Ramp{i, 1}.XB Ramp{i, 1}.YB] =...
            OpenForceRampMultimode(FileNames);
        Ramp{i, 1}.Title = FileNames;
    end
    
    % Initializes propertie of the object Ramp "selected", which 
	% defines whether analysis procedures will be applied to the
	% ramp ( value 1) or not (value 0). 
    Ramp{i, 1}.Property(4) = 1;
    
    % Other properties of the Ramp object are initialized with NaN values.
    % Specifically, these are:
    % Property(5) -> slope from a linear fit
    % Property(6) -> young modulus
    % Property(7) -> contact point
    % Property(8) -> adhesion force
    % Property(9) -> adhesion work
    % Property(10) -> amplitude of exponential fit
    % Property(11) -> characteristic length of exponential fit
    for j=5:11
        Ramp{i, 1}.Property(j) = NaN;
    end
    
    % For linear fitting: this fit is supported in all X and Y
    % representations, but only for one representation at a time. The
    % properties linearFitRepresentationX and linearFitRepresentationY
    % identify the representations for which the linear fit applies
    Ramp{i, 1}.linearFitRepresentationX = NaN;
    Ramp{i, 1}.linearFitRepresentationY = NaN;
end


    
