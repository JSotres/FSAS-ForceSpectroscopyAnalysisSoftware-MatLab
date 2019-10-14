function [zSens, dataType, SamplesPerLine,...
    RampSize, DataLength, DataOffset] =...
    ReadRampHeaderValues(FileName,searchstring)
% ReadRampHeaderValues. Last updated: 08-10-2019 by Javier Sotres. 
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