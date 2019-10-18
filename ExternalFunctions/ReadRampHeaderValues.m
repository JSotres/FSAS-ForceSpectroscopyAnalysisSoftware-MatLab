function [zSens, dataType, SamplesPerLine,...
    RampSize, DataLength, DataOffset] =...
    ReadRampHeaderValues(FileName, searchstring)
% ReadRampHeaderValues.m: Reads Values in Header Text of Nanoscope force
% ramp files.
%
% Input parameters:
%   - FileName -> Name of the force volume file.
%   - searchstring -> cell array containing strings that are located in the
%                     force volume file header, in the same line where 
%                     quantities of interest are, therefore serving as an 
%                     identifier to lacate and read these quantities.
%
% Output parameters:
%   - zSens -> sensitivity in the Z direction
%   - dataType -> type of Y data in the force ramp
%   - SamplesPerLine -> number of points in the force ramp
%   - RampSize -> length of the ramp
%   - DataLength -> size of binary data corresponding to the force ramp
%   - DataOffset -> position of the binary data in the force ramp file
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

% Opens the filefor reading and return an error if unseccesful
fid = fopen(FileName,'r');
[message,errnum] = ferror(fid);
if(errnum)
    fprintf(1,'I/O Error %d \t %s',[errnum,message]);
end

% Inizialization of variables
header_end=0; 
eof = 0; 
RampCounter = zeros(1, 5);

while( and( ~eof, ~header_end ) )
    % Reads the current line from the opened file
    line = fgets(fid);
    % Initializes q and w variables used to string search
    q = [];
    w = [];
    % Different actions are taken depending on which string the lines
    % contains
    if findstr(searchstring(6).label,line)
        % Action to be taken if the line contains information of Z
        % Sensitivity conversion factor
        %
        % Finds the integers in the string line, and stores them in
        % the cell array q
        q = regexp(line,'\d*','Match');
        % Converts q to a single number
        zSens =...
            str2double(strcat(q{length(q)-1}, '.', q{length(q)}));       
    elseif findstr(searchstring(7).label,line)
        % Action to be take if the line contains the string
        % '\*Ciao force image list' i.e. if a header for a ramp is found
        Parameters_Found = 0;
        while Parameters_Found ~= 5 
            % Initializes q and w variables used to string search
            q = [];
            w = [];
            % Read next line of file
            line = fgets(fid);
            % Searchs wether the line containes one of the initial five
            % search strings
            if findstr(searchstring(5).label,line)
                b= findstr(line,'"');
                RampCounter(5) = RampCounter(5)+1;
                dataType{RampCounter(5)} = line(b(1)+1:b(2)-1);
                Parameters_Found = Parameters_Found+1;
            elseif findstr(searchstring(4).label,line)
                % Finds the integers in the string line, and stores them in
                % the cell array q
                q = regexp(line,'\d*','Match');
                % Increments ValueCounter
                RampCounter(4) = RampCounter(4)+1;
                % Converts the strings in q to numbers
                for i = 1:length(q)
                	w(i) = str2double(q{i});
                end
                SamplesPerLine{RampCounter(4)} = w;
                Parameters_Found=Parameters_Found+1;
            elseif findstr(searchstring(3).label,line) 
                q = regexp(line,'\d*','Match');
                % Increments ValueCounter
                RampCounter(3)=RampCounter(3)+1;
                RampSize(RampCounter(3)) =...
                    str2double(strcat(q{length(q)-1},...
                    '.',...
                    q{length(q)}));
                Parameters_Found=Parameters_Found+1;
            elseif findstr(searchstring(2).label,line)
                q = regexp(line,'\d*','Match');
                % Increments ValueCounter
                RampCounter(2)=RampCounter(2)+1;
                DataLength(RampCounter(2)) = str2double(q{1});
                Parameters_Found=Parameters_Found+1;
            elseif findstr(searchstring(1).label,line)
                q = regexp(line,'\d*','Match');
                % Increments ValueCounter
                RampCounter(1)=RampCounter(1)+1;
                DataOffset(RampCounter(1)) = str2double(q{1});
                Parameters_Found=Parameters_Found+1;
            end
        end
    end
    if( (-1)==line )  eof  = 1;  end
	if length( findstr( line, '\*File list end' ) ) header_end = 1;    end
end

% Close the file
fclose(fid);      