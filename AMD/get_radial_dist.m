function [ r ] = get_radial_dist( grid_size, fov_x, fov_y )
%Returns an image of distance calculations of size = grid_size where a
%distance of 0 is assigned to points within 200 pixels of the fovea and
%positive distances begin at the perimeter of this circle

[x,y] = meshgrid(1:grid_size(2),1:grid_size(1));
x = x - fov_x;
y = y - fov_y;

r = sqrt(x.^2+y.^2) - 200;
r(r<0) = 0;
% theta = atan2(y,x);
% coord_img = cat(3,r,theta);
end

