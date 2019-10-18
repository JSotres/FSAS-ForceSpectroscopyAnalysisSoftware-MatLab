function [xnew, ynew] = Ordenar(xold, yold)
% Ordenar.m: Arranges an (x, y) array in incremental values of x.
%
% Input parameters:
%   - xold, yold
%
% Output parameters:
%   - xnew, ynew
%
% Comments and suggestions: 
% Javier Sotres
% Department of Biomedical Science
% Malmoe University, Malmoe, Sweden 
% Email: javier.sotres@mau.se
% http://www.mah.se/sotres

% number of rows of xold
n_rows = max(size(xold));

%performs the actual arrangement
x = xold;
y = yold;
for i = 2:n_rows
    for j = i:-1:2
        if x(j) < x(j-1)
            x_temp = x(j-1);
            y_temp = y(j-1);
            x(j-1) = x(j);
            y(j-1) = y(j);
            x(j) = x_temp;
            y(j) = y_temp;
        end
    end
end
xnew = x;
ynew = y;