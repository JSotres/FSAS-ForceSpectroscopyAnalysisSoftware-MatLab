function CustomHistogram(Quantity,Representation, Min, Max, NBins)
% CustomHistogram.m: plots in an external figure a normalized histogram.
%
% Input variables:
%   - Quantity -> quantity to be used for calculating the histogram
%   - Representation -> indicates the quantity to be plotted and sets the
%   label of the x-axis accordingly. As it is the FSAS software  that calls
%   this function, the following x-labels are implemented:
%       3: topography/height, in nm units
%       5: slope, in nm/V units
%       6: young modulus, in GPa units
%       8: adhesion force, in nN units
%       9: adhesion work, in nm*nN units
%       10: exponential amplitude, in nN units
%       11: exponential length, in nm units
%   - Min -> minimum value of quantity to be used for both calculating and
%   plotting the histogram.
%   - Max -> maximum value of quantity to be used for both calculating and
%   plotting the histogram.
%   - NBins -> number of bins in the histogram.
% 
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

% Calculate the size of the bins, in term of units of the quantity to be
% plotted
IntervalSize = (Max-Min)/NBins;

% Converts "Quantity" into a 1D array (in case it was not originally
Quantity=Quantity(:);

% Calculates a 1D array , HistX, corresponding to the mean values of
% "Quantity" for each histogram bin. It also calculates the minimimum and
% maximum "Quantity" values of each bin, HistMin and HistMax respectively.
for i = 1:NBins
    HistMin(i) = Min+((i-1)*IntervalSize);
    HistMax(i) = HistMin(i)+IntervalSize;
    HistX(i) = (HistMax(i) + HistMin(i))/2;
end

% Calculates a 1D array , HistY, corresponding to the total number of
% "Quantity" components with values falling into tohose corresponding to
% wach histogram bin.
HistY(1:NBins)=0;
for i = 1:length(Quantity)
    for j = 1:NBins
        if Quantity(i) >= HistMin(j) && Quantity(i) < HistMax(j)
            HistY(j) = HistY(j) + 1;
            break;
        end
    end
end

% Normalize HistY over the total number of components in "Quantity"
HistYN = HistY/length(Quantity);

% Definition of a standrd gaussina function
gaussian_fit = @(amp,mu,sigma,x) amp * exp(-(x-mu).^2/(2*sigma^2));

% Fit of the sets of data (HistX, HistY) to a gaussin function
actual_gaussian_fit =...
    fit(HistX', HistYN', gaussian_fit, 'StartPoint',...
    [0.5 nanmean(Quantity) nanmean(Quantity)/2]);

% Initialize the variable Coefficients with the values dfound in the fit
% for the fitting parameters:
% Coefficients = [gaussian_amplitude expected_value gaussian_RMS_width]
Coefficients=coeffvalues(actual_gaussian_fit);

% Plots the normalized histogram in an external figure
figure;
bar(HistX, HistYN);

% Plots the gaussian fit on topof the histogram
hold on
xfit=Min:0.001:Max;
plot(xfit, actual_gaussian_fit(xfit), 'LineWidth', 2);

% Sets label of X axis according to the provided "Representation" input
% parameter
switch Representation
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

% Adds a text box in the figure with the fitting parameters values found in
% the the gaussian fit. Specifically those for the expected value and for
% the gaussian RMS width
dim = [0.2 0.5 0.3 0.3];
str1 =...
    {strcat('mu: ', num2str(Coefficients(2))),...
    strcat('sigma: ', num2str(Coefficients(3)))};
annotation('textbox',dim,'String',str1,'FitBoxToText','on');

%Incorporates a legend in the figure
legend ('data', 'normal distribution fit')

% Sets label for Y axis
ylabel('Probability');
        