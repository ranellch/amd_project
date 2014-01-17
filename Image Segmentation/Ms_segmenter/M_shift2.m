function [Mode, Number_values] = M_shift2 (Values, Window_radius, Initial, Mv)
% assumes that Values contains cumulative information, i.e.
% the number of elements of the particular value in each Values cell

Current_val = round(Initial+2);
Next_val = round(Initial);
L1 = size(Values, 1);  L2 = size(Values, 2);

% global plot_number plot_xmin plot_xmax plot_ymin plot_ymax
% if plot_number == 1
% 	figure;
% end
% [II, JJ] = find(Values > 0);
% if plot_number == 1
% 	plot_xmin = min(II)-Window_radius/2;
% 	plot_xmax = max(II)+Window_radius/2;
% 	plot_ymin = min(JJ)-Window_radius/2;
% 	plot_ymax = max(JJ)+Window_radius/2;
% end
% 
% subplot(2, 2, plot_number);
% plot(II, JJ, '.');
% xlabel('first principal component');
% ylabel('second prrincipal component');
% axis([plot_xmin plot_xmax plot_ymin plot_ymax])
% text(Next_val(1)+Window_radius/1.8, Next_val(2)-Window_radius/4, 'Initial');

while norm(Next_val-Current_val) > 2

%	Draw_rect(Window_radius, Window_radius, Next_val, 'magenta');

	Current_val = Next_val;
	clear x;
   Window = Values(...
		max(1, Current_val(1)-Window_radius): ...
      min(L1, Current_val(1)+Window_radius), ...
		max(1, Current_val(2)-Window_radius): ...
		min(L2, Current_val(2)+Window_radius));
	[x(1, :, :), x(2, :, :)] = ...
      ndgrid(...
      [max(1, Current_val(1)-Window_radius): ...
      min(L1, Current_val(1)+Window_radius)], ...
      [max(1, Current_val(2)-Window_radius): ...
      min(L2, Current_val(2)+Window_radius)]);

	for i=1:2
		Sum_values(1, i) = sum(sum(squeeze(x(i, :, :)) .* Window));
	end
   Number_values = sum(sum(Window));
	
	if Number_values < Mv
		Mode = Initial;
		Number_values = 0;
		return;
	end

   Next_val = round(Sum_values/Number_values);
end
Mode = Next_val;

% text(Next_val(1)+Window_radius/1.8, Next_val(2)+Window_radius/4, 'Final');
% plot_number = plot_number+1;
