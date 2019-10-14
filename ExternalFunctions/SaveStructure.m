function SaveStructure(vargin, label)

[file,path] = uiputfile(label);
savingfile=fullfile(path,file);
save(savingfile,'vargin');