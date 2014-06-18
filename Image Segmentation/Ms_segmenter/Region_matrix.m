function Image = Region_matrix(Region)

Min_x = Region.Shifts(1, 1);
Min_y = Region.Shifts(2, 1);
Max_x = Region.Shifts(1, 2);
Max_y = Region.Shifts(2, 2);

Image = zeros(Max_x-Min_x+1, Max_y-Min_y+1);

Image(sub2ind(size(Image), Region.Boundary(1, :)-Min_x+1, ...
	Region.Boundary(2, :)-Min_y+1)) = 1;

To_start_fill = [Region.Inner_pts(2, :)-Min_y+1; ...
	Region.Inner_pts(1, :)-Min_x+1];
Image = bwfill(Image, To_start_fill(1, :), To_start_fill(2, :));

