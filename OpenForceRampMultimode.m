function [XF, YF, XB, YB] = OpenForceRampMultimode(file_name)
% OpenForceRampMultimode: Reading of Force Ramps obtained with Multimode SPMs
% Last updated: 08-10-2019 by Javier Sotres for reading
% 
% Based on the routine OpenNano6 by Jaco de Groot for opening NanoScope 6
% images with Matlab available at MathWorks
% 
% Javier Sotres
% Biointerfaces group, Faculty of Health and Society, Malm? University
% Email: javier.sotres@mah.se
% http://www.jsotres.es/

searchstring(1).label='\Data offset:';
searchstring(2).label='\Data length:';
searchstring(3).label='\@4:Ramp size:';
searchstring(4).label='\Samps/line';
searchstring(5).label='\@4:Image Data:';
searchstring(6).label='@Sens. Zsens:';
searchstring(7).label='\*Ciao force image list';

[zSens, dataType, samplesPerLine,...
    rampSize, dataLength, dataOffset] =...
    ReadRampHeaderValues(file_name, searchstring);

L = length(dataType);

fid = fopen(file_name,'r');

for i = 1:L
   if strcmp(dataType(i), 'Deflection Error') == 1
       fseek(fid, dataOffset(i), -1);
       CurveRawData(i).Data = fread(fid, dataLength, 'int16');
       JumpStep = (rampSize(i)/samplesPerLine{i}(1))* zSens;
       XF = ones(size(CurveRawData(i).Data,1)/2, 3) * NaN;
       XB = XF;
       YF = ones(size(CurveRawData(i).Data,1)/2, 4) * NaN;
       YB = YF;
       XF(:,1) = (1:samplesPerLine{i}(1))*JumpStep;
       XB(:,1) = (1:samplesPerLine{i}(1))*JumpStep;
       YF(1:samplesPerLine{i}(2),1) =...
           0.000375 * CurveRawData(i).Data(1:samplesPerLine{i}(2));
       YB(:,1) = 0.000375 *...
           CurveRawData(i).Data(size(CurveRawData(i).Data,1)/2+1:end);
   end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [zsens,curve] = read_header_values(file_name,searchstring);
    
% Define End of file identifier
% Opend the file given in argument and reference as
% fid.  Also if there was an error output error
% number and error message to screen
fid = fopen(file_name,'r');
[message,errnum] = ferror(fid);
if(errnum)
	fprintf(1,'I/O Error %d \t %s',[errnum,message]);
end
header_end=0; eof = 0; 
% counter = 1; byte_location = 0;
    
N_Curves=0;
    
while( and( ~eof, ~header_end ) )
   
    line = fgets(fid);
    
    if findstr(searchstring(6).label,line)
        zsens=extract_num(line);
    elseif findstr(searchstring(7).label,line)
        Parameters_Found=0;
        N_Curves=N_Curves+1;
        while Parameters_Found~=5        
            line = fgets(fid);
            for k=1:5
                if findstr(searchstring(k).label,line)
                    if (extract_num(line))
                        b=findstr('LSB',line);
                        if (b>0)
                            curve(N_Curves).param(k)=extract_num(line(b(1):end));
                            Parameters_Found=Parameters_Found+1;
                        else
                            if k==4
                                c=findstr(line,' ');
                                curve(N_Curves).Number_Points=[extract_num(line(c(1):c(2)))  extract_num(line(c(2):end))];
                            else
                                curve(N_Curves).param(k)=extract_num(line);
                            end
                            Parameters_Found=Parameters_Found+1;
                        end
                    else
                        b= findstr(line,'"');
                        curve(N_Curves).DataType=line(b(1)+1:b(2)-1);
                        Parameters_Found=Parameters_Found+1;
                    end
                end
            end
        end
    end
    if( (-1)==line )  eof  = 1;  end     
    if length( findstr( line, '\*File list end' ) ) header_end = 1;    end
end

fclose(fid);      

