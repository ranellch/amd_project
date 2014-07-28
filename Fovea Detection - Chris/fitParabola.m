function [ params ] = fitParabola( points )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x = points(1,:);
y = points(2,:);
%find parameters a and b to best fit parabola
a0 = 0.002;
B0 = 0;
options = optimoptions('lsqnonlin');
options.Display = 'off';
% options.Algorithm = 'levenberg-marquardt';
params = lsqnonlin(@parabola_criterion,[a0,B0],[],[],options);


%define parabola fitting function
function J = parabola_criterion(inits)
    a = inits(1);
    B = inits(2);
    if B == 0
        xprime = x;
        yprime = y;
    else
        %get x and y values in new rotated coordinate system
        xprime = (x*cosd(B)+y*sind(B))/(sind(B)^2+cosd(B)^2);
        yprime = (xprime*cosd(B)-x)/sind(B);
    end
    
    J = a*(xprime*sind(B)+yprime*cosd(B)).^2 ...
            - abs(xprime*cosd(B)-yprime*sind(B));    
end
end

