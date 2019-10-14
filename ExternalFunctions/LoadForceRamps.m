function Ramp = LoadForceRamps(FileNames, FilePath)

% Add selected path 
addpath(FilePath);
cd(FilePath);

% Retrieve the number of loaded force ramps
if iscell(FileNames)
    NumberOfFiles = size(FileNames, 2);
else
    NumberOfFiles = 1;
end

for i=1:NumberOfFiles
    Ramp{i, 1} = ForceRampClass;
    Ramp{i, 1}.FZRepresentationX = [1 0 0];
    Ramp{i, 1}.FZRepresentationY = [1 0 0 0];
    Ramp{i, 1}.AnalysisRepresentation = [0 0 0];
    if NumberOfFiles > 1
        [Ramp{i, 1}.XF Ramp{i, 1}.YF Ramp{i, 1}.XB Ramp{i, 1}.YB] =...
            OpenForceRampMultimode(FileNames{i});
        Ramp{i, 1}.Title = FileNames{i};
    elseif NumberOfFiles == 1
        [Ramp{i, 1}.XF Ramp{i, 1}.YF Ramp{i, 1}.XB Ramp{i, 1}.YB] =...
            OpenForceRampMultimode(FileNames);
        Ramp{i, 1}.Title = FileNames;
    end
    Ramp{i, 1}.Property(4) = 1;
    for j=5:11
        Ramp{i, 1}.Property(j) = NaN;
    end
end


    
