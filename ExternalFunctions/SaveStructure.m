function SaveStructure(vargin, label)
% SaveStructure.m: saves a MatLab structure.
%
% Input parameters:
%   - vargin -> Matlab structure to be saved.
%   - label -> label to be displayed in the graphical interface used for
%              choosing the location and name of the file where the 
%              structure will be saved.
%
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

[file,path] = uiputfile(label);
savingfile=fullfile(path,file);
save(savingfile,'vargin');