function PlotHistInExternalFigure(Map, MapRepresentation,...
    HistMin, HistMax, HistBins)
% Plots in an external figure a histogram of the values in the field Values
% of the input parameter Map
%
% Input Parameters:
% Map -> contains a field "Value" used for histogram calculation
% MapRepresentation -> different number for different information contained
% in Map.Values. Here used only for determining label of X axis. 
%   Possible values:
%       3: height/topography
%       5: slope
%       6: young modulus
%       8: adhesion force
%       9: adhesion work
%       10: exponential amplitude
%       11: exponential length 
% HistMin -> Minimum value of the X axis in the histogram
% HistMax -> Maximum value of the X axis in the histogram
% HistBins -> Number of bins in the histogram


% Opens an external figure and plots a histogram of the input parameter Map
figure;
h=histogram(Map.Value(:));

% Sets the number of bins and limits of the histofram to those provided as
% input parameters
h.NumBins = HistBins;
h.BinLimits = [HistMin HistMax];

% Histogram is normalized
h.Normalization = 'probability';

% Sets label of X axis according to the provided MapRepresentation input
% parameter
switch MapRepresentation
	case 3
        xlabel('Height (nm)');
	case 5
        xlabel('Slope');
	case 6
        xlabel('Young Modulus (GPa)');
	case 8
        xlabel('Adhesion Force (nN)');
	case 9
        xlabel('Adhesion Work (nN*nm)');
	case 10
        xlabel('Exponential Amplitude (nm)');
    case 11
        xlabel('Exponential Length (nm)');
end

% Sets label for Y axis
ylabel('Probability');