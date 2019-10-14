function [IndMin, IndMax] =...
    FromRange2Indexes(InputVector, MinValue, MaxValue)
% Provided and 1D array and a minimum and maximum values, retur the indices
% corresponding to those values in the input vector

SizeInputVector=max(size(InputVector));

for i=1:SizeInputVector
    IndMin = i;
    if InputVector(i)>MinValue
        break;
    end
end

for j=i:SizeInputVector
    IndMax = j;
    if InputVector(j)>MaxValue
        break;
    end
end