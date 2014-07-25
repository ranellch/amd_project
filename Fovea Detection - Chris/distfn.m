function [inliers, M] = distfn(M, points, t)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

x = points(1,:);
y = points(2,:);
npoints = size(x,2);

a = M(1);
B = M(2);

%Rotate coordinate system by B, if necessary
if B ~= 0
    xprime = zeros(1,npoints);
    yprime = zeros(1,npoints);
    for i = 1:length(x)
        xprime(i) = (x(i)*cosd(B)+y(i)*sind(B))/(sind(B)^2+cosd(B)^2);
        yprime(i) = (xprime(i)*cosd(B)-x(i))/sind(B);
    end
else 
    xprime = x;
    yprime = y;
end

%Calculate each point's distance from model
f_y = zeros(npoints,2);
f_y(:,1) = round(a*yprime.^2); %right facing parabola
f_y(:,2) = round(-1*a*yprime.^2); %left facing parabola
inliers = [];
for i = 1:length(x)
    dist = min([abs(f_y(i,1)-xprime(i)),abs(f_y(i,2)-xprime(i))]);
    if dist < t
        inliers = [inliers,i];
    end
end

end

