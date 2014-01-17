function [New_inner_pts, New_boundary, New_shifts] = ...
	Merge_regions (Region1, Region2);

Min_x = min(Region1.Shifts(1, 1), Region2.Shifts(1, 1));
Max_x = max(Region1.Shifts(1, 2), Region2.Shifts(1, 2));
Min_y = min(Region1.Shifts(2, 1), Region2.Shifts(2, 1));
Max_y = max(Region1.Shifts(2, 2), Region2.Shifts(2, 2));

Image1 = zeros(Max_x-Min_x+1, Max_y-Min_y+1);
Image1(sub2ind(size(Image1), Region1.Boundary(1, :)-Min_x+1, ...
	Region1.Boundary(2, :)-Min_y+1)) = 1;
To_start_fill = [Region1.Inner_pts(2, :)-Min_y+1; ...
	Region1.Inner_pts(1, :)-Min_x+1];
Image1 = bwfill(Image1, To_start_fill(1, :), To_start_fill(2, :));

Image2 = zeros(Max_x-Min_x+1, Max_y-Min_y+1);
Image2(sub2ind(size(Image2), Region2.Boundary(1, :)-Min_x+1, ...
	Region2.Boundary(2, :)-Min_y+1)) = 1;
To_start_fill = [Region2.Inner_pts(2, :)-Min_y+1; ...
	Region2.Inner_pts(1, :)-Min_x+1];
Image2 = bwfill(Image2, To_start_fill(1, :), To_start_fill(2, :));

Image1 = or(Image1, Image2);

New_boundary = Extract_region_reg(Image1, 1);
New_boundary = New_boundary + [Min_x-1; Min_y-1]*ones(1, size(New_boundary, 2));
New_inner_pts = [Region1.Inner_pts, Region2.Inner_pts];
New_shifts = [Min_x, Max_x; Min_y, Max_y];
