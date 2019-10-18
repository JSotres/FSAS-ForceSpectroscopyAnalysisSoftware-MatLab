function XTS = TSDistanceConverter(XZ,D)
% TSDistanceConverter.m: In a force ramp, transforms the offset corrected
% sample vertical position X-axis into a probe-sample distance X-axis.
%
% Input parameters:
%   - XZ -> array of offset corrected sample vertical positions.
%   - D -> array of cantileve deflection values.
%
% Output parameters:
%   - XTS -> array of probe-sample distance values.
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

XTS=XZ+D;