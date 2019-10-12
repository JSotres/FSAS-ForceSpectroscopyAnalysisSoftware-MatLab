function HeaderValues = ReadHeaderValues(FileName,SearchString)

% ReadHeaderValues version 0.1.
%
% Last updated: 08-10-2019 by Javier Sotres. 
%
% Reads Values in Header Text of Nanoscope 5 force volume files. Based on 
% the script developed by Jaco de Groot,available at: 
% https://se.mathworks.com/matlabcentral/fileexchange/11515-open-nanoscope-6-afm-images
%
% This function/script is authorized for use in government and academic
% research laboratories and non-profit institutions only. Though this
% function has been tested prior to its posting, it may contain mistakes or
% require improvements. In exchange for use of this free product, we 
% request that its use and any issues that may arise be reported to us. 
% Comments and suggestions are therefore welcome and should be sent to: 
% 
% Javier Sotres
% Biomedical Science, 
% Faculty of Health and Society, Malmo University
% Malmo, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

% Opens the filefor reading and return an error if unseccesful
fid = fopen(FileName,'r');
[message,errnum] = ferror(fid);
if(errnum)
    fprintf(1,'I/O Error %d \t %s',[errnum,message]);
end

% Inizialization of variables
header_end=0; 
eof = 0; 
nstrings=size(SearchString,2);
for ij=1:nstrings 
    ValueCounter(ij)=1; 
end;

while( and( ~eof, ~header_end ) )
    % Reads the current line from the opened file
    line = fgets(fid);
    % A for loop is initialized, with will search for all input stings in
    % the current line        
    for ij=1:nstrings
        % Initializes q and w variables used to string search
        q = [];
        w = [];
        % If the line contains the search string go into the IF condition
        if findstr(SearchString(ij).label,line)
            % Finds the integers in the string line, and stores them in
            % the cell array q
            q = regexp(line,'\d*','Match');
            % Converts the strings in q to numbers
            for i = 1:length(q)
                w(i) = str2double(q{i});
            end
            % If the line contains the strings 'LSB' or '@', just store the
            % last number of the string. If not, store all numerical values
            if ~isempty(findstr('LSB',line)) || ~isempty(findstr('@',line))
                value = str2double(strcat(q{length(q)-1},...
                    '.',...
                    q{length(q)}));
            	HeaderValues(ij).values(ValueCounter(ij)) = value;
            	ValueCounter(ij) = ValueCounter(ij)+1;
            else
                for j=1:length(w)
                    HeaderValues(ij).values(ValueCounter(ij)) = w(j);
                    ValueCounter(ij) = ValueCounter(ij)+1;
                end
            end
        end
    end
    % if the end of the file, or a line containing the string '\*File list
    % end', which in Multimode files indicate the end of the header
    % section, were reached, end the while loop
    if(line == -1)  
        eof  = 1;  
    end     
    if length( findstr( line, '\*File list end' ) ) 
        header_end = 1;    
    end
end
% Close the file
fclose(fid);      