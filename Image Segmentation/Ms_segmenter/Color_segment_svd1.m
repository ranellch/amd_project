function [New_image, Sorted_modes] = ...
   Color_segment_svd (Luv_image, Window_radius, Min_group_size)
% Now first tries to find "the most valuable components" of the image by
% using svd decomposition, which gives 3 matrices - U, having the same number
% of rows as the original vector, and 2 matrices - diagonal which indicates
% weights of the columns, and V which is disregarded at the moment.  Then the
% original meanshift algorithm is applied to either first or two first columns
% of U, both done sufficiently quickly and more or less reliably

% Min_group_size : need at least that many pixels to qualify for a color
Rows = size(Luv_image, 1);
Cols = size(Luv_image, 2);
Min_image_size = 0.05*Rows*Cols;		% to stop when image is small

Luv_vect = reshape(shiftdim(Luv_image, 2), [3, Rows*Cols]);
[U, S, V] = svd(double(Luv_vect'), 0);

% now segmenting based on the first column of U only
U_col = U(:, 1); 
Max = max(U_col);
Min = min(U_col);
U_new = round((U_col-Min*ones(size(U_col)))/(Max-Min)*255);
Gray_image = reshape(U_new, [Rows, Cols]);

% creating a new array - color based
Cumulative = sparse(1, max(max(Gray_image))+1);
for i=1:Rows
   for j=1:Cols
      Cumulative(Gray_image(i, j)+1) = Cumulative(Gray_image(i, j)+1)+1;
   end
end

Cumulative(1) = 0;		% corresponds to only manually zeroed out regions
k = 0; L = length(Cumulative);
while sum(Cumulative) > Min_image_size
   Non_zero_pos = find(Cumulative > 0);
   if length(Non_zero_pos) == 0
      break;
   end
   
   Initial = Non_zero_pos(1);
   [Mode, Number_values] = M_shift1(Cumulative, Window_radius, Initial);
   Mode = full(round(Mode));
   
   if Number_values > Min_group_size	% good group
		k = k+1;
      Modes(k) = Mode;
      Cumulative(max(1, Mode-Window_radius):min(L, Mode+Window_radius)) = ...
      zeros(size(Cumulative(max(1, Mode-Window_radius): ...
      min(L, Mode+Window_radius))));
   else
     	Cumulative(max(1, Initial-Window_radius):min(L, Initial+Window_radius))...
			= zeros(size(Cumulative(max(1, Initial-Window_radius): ...
      	min(L, Initial+Window_radius))));
   end
end

Sorted_modes = sort(Modes);
New_image = zeros(size(Gray_image));
for i=1:k
	To_group = find((Gray_image >= Sorted_modes(i)-Window_radius)...
		& (Gray_image < Sorted_modes(i)+Window_radius));
	New_image(To_group) = i;
end
% Gray_image == 0 added to provide for background detection
To_zero = find(Gray_image == 0);
New_image(To_zero) = 0;
