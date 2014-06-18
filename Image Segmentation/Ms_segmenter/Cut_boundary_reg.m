function [Boundary1, Inner1, Boundary2, Inner2] = ...
   Cut_boundary(Region, Dense_pts)

Min_x = min([Region.Shifts(1, 1), Dense_pts(1, :)]);
Min_y = min([Region.Shifts(2, 1), Dense_pts(2, :)]);
Max_x = max([Region.Shifts(1, 2), Dense_pts(1, :)]);
Max_y = max([Region.Shifts(2, 2), Dense_pts(2, :)]);
Image = zeros(Max_x-Min_x+1, Max_y-Min_y+1);

Image(sub2ind(size(Image), ...
	Region.Boundary(1, :)-Min_x+1, Region.Boundary(2, :)-Min_y+1)) = 1;
Image(sub2ind(size(Image), Dense_pts(1,:)-Min_x+1, Dense_pts(2,:)-Min_y+1)) = 1;

% take the inner points to be close to midpoint of the line, on both sides
Ldp = size(Dense_pts, 2);
Midpt = Dense_pts(:, floor(Ldp/2)) + [1-Min_x; 1-Min_y];
Normal = [Dense_pts(2, Ldp)-Dense_pts(2, 1); Dense_pts(1, 1)-Dense_pts(1, Ldp)];
Normal = Normal/norm(Normal);
Inner1 = Midpt + floor(5*Normal);
Inner2 = Midpt - floor(5*Normal);

Image1 = double(bwfill(Image, Inner1(2), Inner1(1)));
Image2 = bwfill(Image, Inner2(2), Inner2(1));
% not Image has zeros at the position of boundary and cutting line.
% thickening nearly restores the original image boundary
Boundary1 = Extract_region_reg(bwmorph(Image1&not(Image),'thicken'), 1);
Boundary2 = Extract_region_reg(bwmorph(Image2&not(Image),'thicken'), 1);

Boundary1 = Boundary1 + [Min_x-1; Min_y-1]*ones(1, size(Boundary1, 2));
Boundary2 = Boundary2 + [Min_x-1; Min_y-1]*ones(1, size(Boundary2, 2));
Inner1 = Inner1 + [Min_x-1; Min_y-1];
Inner2 = Inner2 + [Min_x-1; Min_y-1];
