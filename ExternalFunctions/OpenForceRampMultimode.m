function [XF, YF, XB, YB] = OpenForceRampMultimode(file_name)
% OpenForceRampMultimode: Reading of Force Ramps obtained with Multimode 
% SPMs
% Last updated: 13-10-2019 by Javier Sotres
% 
% Based on the routine OpenNano6 by Jaco de Groot for reading NanoScope 6
% files available at MathWorks.
%
% Input Parameter:
%   file_name -> name of the force ramp file to be read
%
% Output parameters:
%   XF -> 1D array of the sample vertical positions while approaching the
%         probe (forward direction).
%   XB -> 1D array of the sample vertical positions while withdrawing from
%         the probe (backward direction).
%   YF -> 1D array of the absolute photodetector values while approaching
%         the probe (forward direction).
%   YB -> 1D array of the absolute photodetector values while withdrawing
%         from the probe (backward direction).
% 
% Author: Javier Sotres
% email: javier.sotres@mau.se
% url: mah.se/sotres

% Defines the strings to be searched in the ramp files, they are found in
% the beginning of lones where relevant information is found
%
% Data offset: position of the file where binary information of a ramp is
% placed
searchstring(1).label='\Data offset:';
% Length of the binary data of each ramp in the file
searchstring(2).label='\Data length:';
% Size of the ramp
searchstring(3).label='\@4:Ramp size:';
% Points per line in the ramp
searchstring(4).label='\Samps/line';
% Type of data e.g., Deflection Error, etc.
searchstring(5).label='\@4:Image Data:';
% Sennsitivity in the vertical direction i.e., parameter that should
% multiply the "ramp size" in order to get the length on the ramp in length
% units
searchstring(6).label='@Sens. Zsens:';
% Indicates the position from which the metadata dor a ramp is found in the
% file
searchstring(7).label='\*Ciao force image list';

% Use the external function "ReadRampHeaderValues" to get from the Force
% Ramp Multimode file:
% zSens -> the sensitivity in the vertical dimension
% dataType -> the data type of each ramp contained in the read file
% data Length -> the binary data legth for teh ramps in the file
% dataOffset ->
[zSens, dataType, samplesPerLine,...
    rampSize, dataLength, dataOffset] =...
    ReadRampHeaderValues(file_name, searchstring);

% Number of ramps contained in the file
numberOfRamps = length(dataType);

% Open the ramp filefor reading
fid = fopen(file_name,'r');

for i = 1:numberOfRamps
    % Go thorugh all ramps in the file and identify the one containing
    % "Deflection Error" data
	if strcmp(dataType(i), 'Deflection Error') == 1
        % Go to the position in the file where binary data for the
        % "Deflection Error" ramp is
        fseek(fid, dataOffset(i), -1);
        
        % Read the data of the "Deflection Error" ramp
        CurveRawData(i).Data = fread(fid, dataLength, 'int16');
        
        % Calculate the distance between points in the ramp, "JumpStep"
        JumpStep = (rampSize(i)/samplesPerLine{i}(1))* zSens;
        
        % Based on the parameter "JumpStep" and on the total length of the
        % ramps, create the X(F/B)(:,1) (sample displacement positions)
        % and Y(F/B)(:,1), absolute photodetector values, of the ramps,
        % both in the forward and backward directions.
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