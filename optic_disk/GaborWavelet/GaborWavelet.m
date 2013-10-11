function res = GaborWavelet(x,y,m,n,k,l,param,phase)

% a0 = 2;
% b0 = 0.8;
% theta0 = pi / 8;
a0 = param.a0;
b0 = param.b0;
theta0 = param.theta0;

xx = a0^(-m)*x - n*b0;
yy = a0^(-m)*y - k*b0;

rotX =  xx * cos(l*theta0) + yy * sin(l*theta0);
rotY = -xx * sin(l*theta0) + yy * cos(l*theta0);

res = a0^(-m) * motherWavelet(rotX, rotY,param,phase);