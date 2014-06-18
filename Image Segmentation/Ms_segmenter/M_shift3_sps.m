function [Mode, Number_values, Flag] = M_shift3 (Values, Window_radius, Initial, Min_number)
% assumes that Values contains cumulative information, i.e.
% the number of elements of the particular value in each Values cell

Current_val = round(Initial+2);Next_val = round(Initial);
L1 = length(Values);
L2 = size(Values{1}, 1);
L3 = size(Values{1}, 2);

while norm(Next_val-Current_val) > 1
   Current_val = Next_val;
   clear x; Sum_values(1, 1:3) = zeros(1, 3);Number_values = sparse(1, L1);
   for i=max(1, Current_val(1)-Window_radius):min(L1, Current_val(1)+Window_radius)
      [x(1, :, :), x(2, :, :)] = ...
         ndgrid(...
         [max(1, Current_val(2)-Window_radius): ...
            min(L2, Current_val(2)+Window_radius)], ...
         [max(1, Current_val(3)-Window_radius): ...
            min(L3, Current_val(3)+Window_radius)]);
      
      Window = Values{i}(...
         max(1, Current_val(2)-Window_radius): ...
         min(L2, Current_val(2)+Window_radius), ...
         max(1, Current_val(3)-Window_radius): ...
         min(L3, Current_val(3)+Window_radius));
      
      Number_values(i) = sum(sum(Window));
      Sum_values(1, 1) = Sum_values(1, 1) + Number_values(i)*i;
      
      for j=1:2
         Sum_values(1, j+1) = Sum_values(1, j+1)+sum(sum(squeeze(x(j, :, :)) .* Window));
      end
   end
   
   Number_values_sum = sum(Number_values);
   
   if Number_values_sum < Min_number
      Mode = Initial;
      Flag = 1;
return;
   end
   
   Next_val = round(Sum_values/Number_values_sum);
end
% Mode = Next_val;
Mode = Current_val;
Flag = 0;

