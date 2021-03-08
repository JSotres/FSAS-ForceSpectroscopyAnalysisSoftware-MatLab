function HeaderValues = ReadHeaderValues(FileName,SearchString)
% ReadHeaderValues.m: Reads Values in Header Text of Nanoscope 5 force 
% volume files.
%
% Input parameters:
%   - FileName -> Name of the force volume file.
%   - SearchString -> cell array containing strings that are located in the
%                     force volume file header, in the same line where 
%                     quantities of interest are, therefore serving as an 
%                     identifier to lacate and read these quantities.
%
% OutputParameters: 
%   - HeaderValues -> Values of interest located in the force volume file
%                     header.
%
% Based on the script developed by Jaco de Groot,available at: 
% https://se.mathworks.com/matlabcentral/fileexchange/11515-open-nanoscope-6-afm-images
%
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

% Opens the filefor reading and return an error if unsuccesful
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
        if ij == 7
            if findstr(SearchString(ij).label{1},line)
                condition = true;
            elseif findstr(SearchString(ij).label{2},line)
                condition = true;
            else
                condition = false;
            end
        else
            condition = findstr(SearchString(ij).label,line);
        end
        if condition
            if ij == 11
                m = split(line,'Ciao ');
                m = split(m(2),' list');
                HeaderValues(ij).values(ValueCounter(ij)) = m(1);
                ValueCounter(ij) = ValueCounter(ij)+1;
            elseif ij == 10
                m = split(line,'"');
                HeaderValues(ij).values(ValueCounter(ij)) = m(2);
                ValueCounter(ij) = ValueCounter(ij)+1;
            else
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