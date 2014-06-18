function [New_image, Modes] = Color_segm_sps (Luv_img, Wind, Min_group_size)
% Color_segment - segment an Luv image according to Meer's algorithm
% gets image from the caller, finds significant maxima by mean shift algo 
% groups all the pixels 
% whose color falls within the given interval (with peak being the 
% center, and Window_radius being the radius), 
% Min_group_size : need at least that many pixels to qualify for a color

Step = 4;
% Step = 1;
Max_axis = 255;
Rows = size(Luv_img, 1);
Cols = size(Luv_img, 2);
Luv_image = Luv_img(1:Step:Rows, 1:Step:Cols, :);% taking part of it only
Min_image_size = 0.005*Rows/Step*Cols/Step;% to stop when image is small

Luv_vect = reshape(shiftdim(Luv_image, 2), ...
	[3, size(Luv_image, 1)*size(Luv_image, 2)]);
Max_luv = max(Luv_vect, [], 2);% scaling it
for i=1:3
   Luv_vect(i, :) = floor(Luv_vect(i, :)/(Max_luv(i)+1)*Max_axis)+1;
end

Wind = round(Wind/255*Max_axis);% as if the max was 255

% creating a new array - color based
for i=1:Max_axis+1
   Cumulative{i} = sparse(Max_axis+1, Max_axis+1);
end

Nz = sparse(1, Max_axis+1);
for i=1:size(Luv_vect, 2)
   Cumulative{Luv_vect(1, i)}(Luv_vect(2, i), Luv_vect(3, i)) = ...
      Cumulative{Luv_vect(1, i)}(Luv_vect(2, i), Luv_vect(3, i))+1;
   Nz(Luv_vect(1, i)) = Nz(Luv_vect(1, i))+1;
end

% for background detection only
Cumulative{1} = sparse(Max_axis+1, Max_axis+1);
Nz(1) = 0;

k = 0; L = Max_axis+1;
while sum(Nz) > Min_image_size
   Non_zero_pos = find(Nz > 0);
   if length(Non_zero_pos) == 0
      break;
   end
   Init(1) = Non_zero_pos(1);
   Non_zero_pos_slice = find(Cumulative{Init(1)} > 0);
   if length(Non_zero_pos_slice) == 0
      fprintf('Something is wrong\n');
		break;
   end
   
   [Init(2), Init(3)] = ind2sub(size(Cumulative{Init(1)}), ...
		Non_zero_pos_slice(1));
   
   [Mode, Number_values, Flag] = M_shift3_sps(Cumulative, Wind, ...
		Init, Min_image_size/5);
   
   if not(Flag)% good group
		k = k+1;
      Modes(:, k) = Mode';
      Nz = Nz-Number_values;
      for i=max(1, Mode(1)-Wind):min(L, Mode(1)+Wind)
         Cumulative{i}(...
            max(1, Mode(2)-Wind):min(L, Mode(2)+Wind), ...
            max(1, Mode(3)-Wind):min(L, Mode(3)+Wind)) = ...
          zeros(size(Cumulative{i}(...
            max(1, Mode(2)-Wind):min(L, Mode(2)+Wind), ...
            max(1, Mode(3)-Wind):min(L, Mode(3)+Wind))));
      end
   else
      Nz = Nz-Number_values;
      for i=max(1, Mode(1)-Wind):min(L, Mode(1)+Wind)
         Cumulative{i}(...
            max(1, Mode(2)-Wind):min(L, Mode(2)+Wind), ...
            max(1, Mode(3)-Wind):min(L, Mode(3)+Wind)) = ...
          zeros(size(Cumulative{i}(...
            max(1, Mode(2)-Wind):min(L, Mode(2)+Wind), ...
            max(1, Mode(3)-Wind):min(L, Mode(3)+Wind))));
      end
   end
end

Luv_vect = reshape(shiftdim(Luv_img, 2), [3, Rows*Cols]);
for i=1:3
   Luv_vect(i, :) = floor(Luv_vect(i, :)/(Max_luv(i)+1)*Max_axis)+1;
end

Ones = ones(1, size(Luv_vect, 2));
New_image = zeros(1, size(Luv_vect, 2));
for i=1:size(Modes, 2)
   Center = Modes(:, i) * Ones;
   Norms = max(abs(Center - Luv_vect));
   To_take = find(Norms <= Wind);
   New_image(To_take) = i;
end

% detecting background
To_zero = find(Luv_vect(1, :) == 0);
New_image(To_zero) = 0;
New_image = reshape(New_image, [Rows, Cols]);   
