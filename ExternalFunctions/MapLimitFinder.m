function [MinimumRow,MaximumRow,MinimumColumn,MaximumColumn]=MapLimitFinder(AllOrEach,MaxX,MaxY,ActualX,ActualY)

if AllOrEach==1
    MinimumRow=1;
    MaximumRow=MaxX;
    MinimumColumn=1;
    MaximumColumn=MaxY;
elseif AllOrEach==0
    MinimumRow=ActualX;
    MaximumRow=ActualX;
    MinimumColumn=ActualY;
    MaximumColumn=ActualY;
end