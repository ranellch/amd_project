function Answer = Neighbor(Region1, Region2)

Min_x = min(Region1.Shifts(1, 1), Region2.Shifts(1, 1));
Max_x = max(Region1.Shifts(1, 2), Region2.Shifts(1, 2));
Min_y = min(Region1.Shifts(2, 1), Region2.Shifts(2, 1));
Max_y = max(Region1.Shifts(2, 2), Region2.Shifts(2, 2));

Image1 = zeros(Max_x-Min_x+3, Max_y-Min_y+3);
Image1(sub2ind(size(Image1), Region1.Boundary(1, :)-Min_x+2, ...
		Region1.Boundary(2, :)-Min_y+2)) = 1;
Image1 = double(bwmorph(Image1, 'thicken'));
Image2 = zeros(Max_x-Min_x+3, Max_y-Min_y+3);
Image2(sub2ind(size(Image2), Region2.Boundary(1, :)-Min_x+2, ...
		Region2.Boundary(2, :)-Min_y+2)) = 1;
Image2 = double(bwmorph(Image2, 'thicken'));

Image1 = Image1+Image2;

if length(find(Image1>1))>0		% there are some points with value of 2
	Answer = 1;
else
	Answer = 0;
end
