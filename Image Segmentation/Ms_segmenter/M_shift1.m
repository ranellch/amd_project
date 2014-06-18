function [Mode, Number_values] = M_shift1 (Values, Window_radius, Initial)
% assumes that Values contains cumulative information, i.e.
% the number of elements of the particular value in each Values cell

Current_val = round(Initial+2);
Next_val = round(Initial);
L = size(Values, 2);

% global plot_number plot_xmin plot_xmax plot_ymin plot_ymax
% if plot_number == 1
% 	figure;
% end
% II = find(Values > 0);
% if plot_number == 1
% 	plot_xmin = min(II)-Window_radius/2;
% 	plot_xmax = max(II)+Window_radius/2;
% 	plot_ymin = min(Values)-Window_radius/2;
% 	plot_ymax = max(Values)+Window_radius/2;
% end
% subplot(2, 2, plot_number);
% plot(Values, '.');
% xlabel('feature space (intensity)');
% ylabel('density');
% axis([plot_xmin plot_xmax plot_ymin plot_ymax])
% text(Next_val+Window_radius, Values(Next_val)-Window_radius/4, 'Initial');

while abs(Next_val-Current_val) > 1

%	Draw_rect(1.8*Window_radius, Window_radius, [Next_val, Values(Next_val)], 'magenta');

	Current_val = Next_val;
   Range = [max(1, Current_val-Window_radius): ...
      min(L, Current_val+Window_radius)];
   Window = Values(Range);
   Sum_values = full(Window * Range');
   Number_values = full(sum(Window));
   if Number_values > 0
      Next_val = round(Sum_values/Number_values);
   end
end
Mode = Next_val;

% text(Next_val+Window_radius, Values(Next_val)+Window_radius/4, 'Final');
% plot_number = plot_number + 1;
