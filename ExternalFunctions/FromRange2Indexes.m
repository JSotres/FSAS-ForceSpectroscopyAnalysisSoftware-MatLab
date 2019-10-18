function [IndMin, IndMax] =...
    FromRange2Indexes(InputArray, MinValue, MaxValue)
% FromRange2Indexes.m: Provided an array and a minimum and maximum 
% values, returns the indices corresponding to those values in the input 
% array
%
% Input Parameters:
%   - InputArray -> array from where indices of minimum and maximum values
%   are to be calculated
%   - MinValue -> minimum value of InputArray
%   MaxValue -> maximum value of InputArray
%
% Output Parameters:
%   - IndMin -> index corresponding to MinValue in InputArray
%   - IndMax -> index corresponding to MaxValue in InputArray
%
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

% Calculation of the length of the input array
LengthInputArray=max(size(InputArray));

% Calculation of the index of InputArray corresponsing to MinValue
for i=1:LengthInputArray
    IndMin = i;
    if InputArray(i) > MinValue
        break;
    end
end

% Calculation of the index of InputArray corresponsing to MaxValue
for j=i:LengthInputArray
    IndMax = j;
    if InputArray(j) > MaxValue
        break;
    end
end