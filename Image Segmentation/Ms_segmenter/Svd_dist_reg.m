function [Svd_dist_bdry, Svd_dist_reg] = Svd_dist (Region1, Region2)
% first represent the two boundaries as matrices where ones stand for
% boundary pixels and zeros elsewhere, next use SVD decomposition to
% find eigenvalues, and finally adjust those (take shorter array and
% multiply it by the lengths ratio) - observed from resizing the same
% image

Subints = 8;

 
if length(Region1.Boundary) < length(Region2.Boundary)	% rotate 1 is quicker
	Temp = Region1;
	Region1 = Region2;
	Region2 = Temp;
end


% finding the first region boundary and filled
Max_x1 = Region1.Shifts(1, 2); Min_x1 = Region1.Shifts(1, 1);
Max_y1 = Region1.Shifts(2, 2); Min_y1 = Region1.Shifts(2, 1);
Mb1 = zeros(Max_x1-Min_x1+1, Max_y1-Min_y1+1);
Mb1(sub2ind(size(Mb1), Region1.Boundary(1, :)-Min_x1+1, ...
	Region1.Boundary(2, :)-Min_y1+1)) = 1;
	
Bdry_diag1 = svd(Mb1);
To_start_fill = [Region1.Inner_pts(2, :)-Min_y1+1; ...
	Region1.Inner_pts(1, :)-Min_x1+1];
Mb1 = bwfill(Mb1, To_start_fill(1, :), To_start_fill(2, :));

% global Mb1f;
% Mb1f = Mb1;
% global Mb2f;

Reg_diag1 = svd(double(Mb1));
Ld1 = length(Reg_diag1);
[Rows1, Cols1] = size(Mb1);

% finding the second region filled
Max_x2 = Region2.Shifts(1, 2); Min_x2 = Region2.Shifts(1, 1);
Max_y2 = Region2.Shifts(2, 2); Min_y2 = Region2.Shifts(2, 1);
Mb2_orig = zeros(Max_x2-Min_x2+1, Max_y2-Min_y2+1);
Mb2_orig(sub2ind(size(Mb2_orig), Region2.Boundary(1, :)-Min_x2+1, ...
	Region2.Boundary(2, :)-Min_y2+1)) = 1;
To_start_fill = [Region2.Inner_pts(2, :)-Min_y2+1; ...
	Region2.Inner_pts(1, :)-Min_x2+1];
Mb2_orig = bwfill(Mb2_orig, To_start_fill(1, :), To_start_fill(2, :));

% Mb2f = Mb2_orig;

[Rows, Cols] = find(Mb2_orig);
Mb2_orig = [Rows'; Cols'];

for i=1:Subints+1
	% obtaining rotated second filled and extracting boundary next
	Theta = (i-1)*(pi/2)/(Subints+1);
	Matrix = [cos(Theta), sin(Theta); -sin(Theta), cos(Theta)];
	Mb2_ind = Matrix * Mb2_orig;
	Mb2_ind = [round(Mb2_ind), floor(Mb2_ind), ceil(Mb2_ind)];
	Max_x2 = max(Mb2_ind(1, :)); Min_x2 = min(Mb2_ind(1, :));
	Max_y2 = max(Mb2_ind(2, :)); Min_y2 = min(Mb2_ind(2, :));
	Mb2 = zeros(Max_x2-Min_x2+1, Max_y2-Min_y2+1);
	Mb2(sub2ind(size(Mb2), Mb2_ind(1, :)-Min_x2+1, Mb2_ind(2, :)-Min_y2+1)) = 1;
	Reg_diag2 = svd(Mb2);
	Ld2 = length(Reg_diag2);
	Mb2 = double(bwperim(Mb2));
	Bdry_diag2 = svd(Mb2);
	[Rows2, Cols2] = size(Mb2);

	if Ld1 > Ld2
		Bdry_diag_1 = Bdry_diag1(1:Ld2);
		Reg_diag_1 = Reg_diag1(1:Ld2);
	else
		Bdry_diag_1 = Bdry_diag1;
		Reg_diag_1 = Reg_diag1;
		Bdry_diag2 = Bdry_diag2(1:Ld1);
		Reg_diag2 = Reg_diag2(1:Ld1);
	end

	Factor = sqrt((Rows1*Cols1)/(Rows2*Cols2));
	if Factor > 1
		Bdry_diag2 = Bdry_diag2*Factor;
		Reg_diag2 = Reg_diag2*Factor;
	 else
		Bdry_diag1 = Bdry_diag1/Factor;
		Reg_diag1 = Reg_diag1/Factor;
	end

	Svd_dist_bdry(i) = norm(Bdry_diag_1-Bdry_diag2);
	Svd_dist_reg(i) = norm(Reg_diag_1-Reg_diag2);
end

Svd_dist_bdry = min(Svd_dist_bdry);
Svd_dist_reg = min(Svd_dist_reg);
