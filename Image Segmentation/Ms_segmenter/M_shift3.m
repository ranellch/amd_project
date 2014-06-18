function [Mode, Number_values] = M_shift3 (Values, Window_radius, Initial)
% assumes that Values contains cumulative information, i.e.
% the number of elements of the particular value in each Values cell

Current_val = round(Initial+2);Next_val = round(Initial);
L1 = size(Values, 1);L2 = size(Values, 2);L3 = size(Values, 3);
Min_number_values = 1; % Window_radius^4

while norm(Next_val-Current_val) > 1
   Current_val = Next_val;
   clear x;
   [x(1, :, :, :), x(2, :, :, :), x(3, :, :, :)] = ...
      ndgrid(...
      [max(1, Current_val(1)-Window_radius): ...
      min(L1, Current_val(1)+Window_radius)], ...
      [max(1, Current_val(2)-Window_radius): ...
      min(L2, Current_val(2)+Window_radius)], ...
      [max(1, Current_val(3)-Window_radius): ...
      min(L3, Current_val(3)+Window_radius)]);
   
   Window = Values(...
      max(1, Current_val(1)-Window_radius): ...
      min(L1, Current_val(1)+Window_radius), ...
      max(1, Current_val(2)-Window_radius): ...
      min(L2, Current_val(2)+Window_radius), ...
      max(1, Current_val(3)-Window_radius): ...
      min(L3, Current_val(3)+Window_radius));
   
   for i=1:3
      Sum_values(1, i) = sum(sum(sum(squeeze(x(i, :, :, :)) .* Window)));
   end
   
   Number_values = sum(sum(sum(Window)));
   
   if Number_values < Min_number_values
      Mode = Initial;
      Number_values = 0;
      return;
   end
   
   Next_val = round(Sum_values/Number_values);
end
Mode = Next_val;

