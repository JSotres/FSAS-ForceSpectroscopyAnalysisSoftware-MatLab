function [E, x0, xDataFull, YDataFull] =...
    HertzXOffsetDetermination (xOriginal, yOriginal, xOriginalFull, yOriginalFull,kc, R, PoissonRatio)
% HertzXOffsetDetermination.m: Fits provided data with the Hertz Contact 
% Model (sphere-plane).
%
% Input parameters:
%   - xOriginal -> cantilever deflection values
%   - yOriginal -> absolute sample vertical positions
%   - kc -> cantilever spring constant
%   - R -> probe radius
%   - PoissonRatio -> Poisson ratio
%
% Output parameters:
%   - E -> Young modulus
%   - x0 -> contact point
%   - xData -> cantilever deflection values derived from the Hertz fit
%    -yData -> sample vertical values derived from the Hertz fit
%
% NOTE: different units for the used quantities are not supported in this
% version. It is assumed that:
% xOriginal, yOriginal and R are provided in [nm]
% kc is`provided in [nm]
% If so:
% Units of x0, xData and yData are [nm]
% Units of E are GPa
%
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% https://www.jsotres.com

% It require arranging xData and Ydata in incremental
% values of xData, which is done by calling the external
% function "Ordenar" 
[xData,Ydata] = Ordenar(xOriginal,yOriginal);

[xDataFull,YDataFull] = Ordenar(xOriginalFull, yOriginalFull);

% The function corresponding to the Hertz fit is defined
Hertz_FitType = fittype(@(K2,Z0,x) -K2*x.^(2/3)-x+Z0);
% And the fit is performed
Fit1 = fit(xData, Ydata, Hertz_FitType, 'StartPoint',[0.5 20]);

Coefficients = coeffvalues(Fit1);
if Coefficients(1)>0
    % If the K2 parameter is positive, the Young modulus and contact
    % position (output parametes) are assigned. We also output the 
    % reduced Young modulus, Et, which will be used to calculate the
    % contact radius later on
    E = 3*(1-PoissonRatio^2)*kc/(4*R^(0.5)*Coefficients(1)^(3/2));
    x0 = Coefficients(2);
else
    % If the K2 parameter is negative, which will happen if the slope of
    % the contact region is lower than the photodetector sensitivity, the
    % output Young moduli and contact positions are assigned NaN values
    E = NaN;
    x0 = NaN;
end

% The output X and Y values of the Hertz fit are calculated
xDataFull = 0:0.1:max(xDataFull);
YDataFull = -Coefficients(1)*xDataFull.^(2/3)-xDataFull;

end