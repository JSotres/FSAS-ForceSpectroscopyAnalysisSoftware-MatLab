function CustomHistogram(Quantity,Representation, Min, Max, NBins)

IntervalSize = (Max-Min)/NBins;
Quantity=Quantity(:);
for i = 1:NBins
    HistMin(i) = Min+((i-1)*IntervalSize);
    HistMax(i) = HistMin(i)+IntervalSize;
    HistX(i) = (HistMax(i) + HistMin(i))/2;
end

HistY(1:NBins)=0;
for i = 1:length(Quantity)
    for j = 1:NBins
        if Quantity(i) >= HistMin(j) && Quantity(i) <= HistMax(j)
            HistY(j) = HistY(j) + 1;
            break;
        end
    end
end

HistYN = HistY/length(Quantity);

gaussian_fit = @(amp,mu,sigma,x) amp * exp(-(x-mu).^2/(2*sigma^2));

actual_gaussian_fit = fit(HistX', HistYN', gaussian_fit, 'StartPoint', [0.5 nanmean(Quantity) nanmean(Quantity)/2]);
Coefficients=coeffvalues(actual_gaussian_fit)
figure;

bar(HistX, HistYN);

hold on

xfit=Min:0.001:Max;
c=actual_gaussian_fit(xfit)
plot(xfit, actual_gaussian_fit(xfit), 'LineWidth', 2);

% Sets label of X axis according to the provided MapRepresentation input
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

dim = [0.2 0.5 0.3 0.3];

str1 = {strcat('mu: ', num2str(Coefficients(2))), strcat('sigma: ', num2str(Coefficients(3)))};
annotation('textbox',dim,'String',str1,'FitBoxToText','on');

legend ('data', 'normal distribution fit')

% Sets label for Y axis
ylabel('Probability');
        