function [E, x0, xData,yData]=HertzXOffsetDetermination (xOriginal, yOriginal, kc, R, PoissonRatio)

[xData,Ydata]=Ordenar(xOriginal,yOriginal);
Hertz_FitType=fittype(@(K2,Z0,x) -K2*x.^(2/3)-x+Z0);
Fit1=fit(xData, Ydata, Hertz_FitType, 'StartPoint',[0.5 20]);
Coefficients=coeffvalues(Fit1);
if Coefficients(1)>0
    E=3*(1-PoissonRatio^2)*kc/(4*R^(0.5)*Coefficients(1)^(3/2));
    x0=Coefficients(2);
else
    E=NaN;
    x0=NaN;
end

xData=0:0.1:max(xData);
yData=-Coefficients(1)*xData.^(2/3)-xData;
%y=-Coefficients(1)*Xdata.^(2/3)-Xdata+Coefficients(2);
%Xdata=Xdata-x0;

end