n=256;
x = [0:n/2-1,-n/2:-1];
s=3;
[Y,X] = meshgrid(x,x);
h = exp( (-X.^2-Y.^2)/(2*s^2) );