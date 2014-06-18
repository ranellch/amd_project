function [New_image, Modes] = ...
   Color_segment_svd2 (Luv_image, Wind, Min_group_size)
% Now first tries to find "the most valuable components" of the image by
% using svd decomposition, which gives 3 matrices - U, having the same number
% of rows as the original vector, and 2 matrices - diagonal which indicates
% weights of the columns, and V which is disregarded at the moment.  Then the
% original meanshift algorithm is applied to either first or two first columns
% of U, both done sufficiently quickly and more or less reliably

% Min_group_size : need at least that many pixels to qualify for a color
Rows = size(Luv_image, 1);
Cols = size(Luv_image, 2);
Min_image_size = 0.005*Rows*Cols;		% to stop when image is small

Luv_vect = reshape(shiftdim(Luv_image, 2), [3, Rows*Cols]);
[U, S, V] = svd(double(Luv_vect'), 0);

% now segmenting based on the first and second columns of U only
U_col = U(:, 1:2);
U_col(:, 2) = U_col(:, 2)*S(2, 2)/S(1, 1);		% scaling it
Max = max(max(U_col));
Min = min(min(U_col));
Max_axis = 255;
U_new = round((U_col-Min*ones(size(U_col)))/(Max-Min)*Max_axis)';

% creating a new matrix - color based
Cumulative = sparse(Max_axis+1, Max_axis+1);
for i=1:size(U_new, 2)
	Cumulative(U_new(1, i)+1, U_new(2, i)+1) = ...
		Cumulative(U_new(1, i)+1, U_new(2, i)+1) + 1;
end

% for background detection only
Cumulative(1, 1) = 0;

k = 0; L = Max_axis+1;  Max_iterats = 1000;
while sum(sum(Cumulative)) > Min_image_size
   Non_zero_pos = find(Cumulative > 0);
   if length(Non_zero_pos) == 0
      break;
   end
   
	[Init(1), Init(2)] = ind2sub(size(Cumulative), Non_zero_pos(1));
   
   [Mode, Number_values] = M_shift2(Cumulative, Wind, Init, Min_group_size/5);
   Mode = full(round(Mode));
   if Number_values > Min_group_size	% good group
		k = k+1;
      Modes(:, k) = Mode';
		Cumulative(...
         max(1, Mode(1)-Wind):min(L, Mode(1)+Wind), ...
         max(1, Mode(2)-Wind):min(L, Mode(2)+Wind)) = ...
         zeros(size(Cumulative(...
         max(1, Mode(1)-Wind):min(L, Mode(1)+Wind), ...
         max(1, Mode(2)-Wind):min(L, Mode(2)+Wind))));
   else
		Cumulative(...
         max(1, Mode(1)-Wind):min(L, Mode(1)+Wind), ...
         max(1, Mode(2)-Wind):min(L, Mode(2)+Wind)) = ...
         zeros(size(Cumulative(...
         max(1, Mode(1)-Wind):min(L, Mode(1)+Wind), ...
         max(1, Mode(2)-Wind):min(L, Mode(2)+Wind))));
   end
	Max_iterats = Max_iterats-1;
	if Max_iterats < 0
		break;
	end
end

Ones = ones(1, size(Luv_vect, 2));
New_image = zeros(1, size(Luv_vect, 2));
for i=1:size(Modes, 2)
   Center = Modes(:, i) * Ones;
   Norms = max(abs(Center - U_new));
   To_take = find(Norms <= Wind);
   New_image(To_take) = i;
end
% detecting background
To_zero = find(Luv_vect(1, :) == 0);
New_image(To_zero) = 0;
New_image = reshape(New_image, [size(Luv_image, 1), size(Luv_image, 2)]);
