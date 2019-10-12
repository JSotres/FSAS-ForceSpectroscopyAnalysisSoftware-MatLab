function [IndMin,IndMax]=FromRange2Indexes(InputVector,MinValue,MaxValue)

SizeInputVector=max(size(InputVector));

for i=1:SizeInputVector
    IndMin=i;
    InputVector(i);
    if InputVector(i)>MinValue
        break;
    end
end

for j=i:SizeInputVector
    IndMax=j;
    InputVector(j);
    if InputVector(j)>MaxValue
        break;
    end
end