function [xnew, ynew]=Ordenar(xold,yold)

%matriz_temporal=load(matriz_desordenada);

n_filas=max(size(xold));

x=xold;
y=yold;


for i=2:n_filas
    for j=i:-1:2
        if x(j)<x(j-1)
            x_temp=x(j-1);
            y_temp=y(j-1);
            x(j-1)=x(j);
            y(j-1)=y(j);
            x(j)=x_temp;
            y(j)=y_temp;
        end
    end
end

xnew=x;
ynew=y;



%plot(x,y,'o','MarkerSize',2);

