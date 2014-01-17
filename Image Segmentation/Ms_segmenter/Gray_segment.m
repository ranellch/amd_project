function [New_image, Sorted_modes] = ...
   Gray_segm (Gray_image, Window_radius, Min_group_size)
% Gray_segment - segment a gray-level image according to Meer's algorithm
% reads image from the file, finds significant maxima by mean shift algo 
% (to generalize to the case of 3-d vectors), groups all the pixels 
% whose color falls within the given interval (with peak being the 
% center, and Window_radius being the radius), 

% Min_group_size : need at least that many pixels to qualify for a color

Rows = size(Gray_image, 1);
Cols = size(Gray_image, 2);
Min_image_size = 0.005*Rows*Cols;		% to stop when image is small
Gray_image = round(Gray_image);

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
   
   if Number_values > Min_group_size% good group
		k = k+1;
      Modes(k) = Mode;
      Cumulative(max(1, Mode-Window_radius):min(L, Mode+Window_radius)) = ...
      zeros(size(Cumulative(max(1, Mode-Window_radius): ...
      min(L, Mode+Window_radius))));
   else
      Cumulative(max(1,Initial-Window_radius):min(L,Initial+Window_radius)) =...
      zeros(size(Cumulative(max(1, Initial-Window_radius): ...
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
