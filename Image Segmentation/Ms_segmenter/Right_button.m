if Interactive
	Region_right{I} = Region_left{I};
	Choice_right = uicontrol('Parent', New_wind);
	Call_back_right = ...
   	sprintf('Segment_demo(''Right'', %18.16f, %d)', Choice_right, I);
	set(Choice_right, 'Style', 'Popup', 'String', Regions_disp, ...
   	'Units', 'Normalized', 'Position', [0.55 0.5 0.45 0.5], ...
   	'Callback', Call_back_right);
else
	if Region_right{I} == 0
		msgbox('Please select 2-nd region', '2-nd region needed');
	end
	return;
end
