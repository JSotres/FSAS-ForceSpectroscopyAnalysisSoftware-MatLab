function PlotHistInExternalFigure(Map, MapRepresentation, HistMin, HistMax, HistBins)

figure;
h=histogram(Map.Value(:));
h.NumBins = HistBins;
h.BinLimits = [HistMin HistMax];
h.Normalization = 'probability';
switch MapRepresentation
	case 3
        xlabel('Height (nm)');
	case 6
        xlabel('Young Modulus (GPa)');
	case 8
        xlabel('Adhesion Force (nN)');
	case 10
        xlabel('Exponential Amplitude (nm)');
    case 11
        xlabel('Exponential Length (nm)');
end
ylabel('Probability');