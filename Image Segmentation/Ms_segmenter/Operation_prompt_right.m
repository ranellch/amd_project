if Region_right{I} == 0
	% prompt for an operation - one region only
	Scr_sz = get(0, 'ScreenSize');
	New_wind = dialog('Name', 'Choose region(s)', 'Position', ...
	   [Scr_sz(3)*0.3 Scr_sz(4)*0.4 Scr_sz(3)*0.3 Scr_sz(4)*0.1]);
	
	k = 0;  Ok_button = 0;	Interactive = 1;
	if Show_all_regions{I}		% not just active
		k = Bndred_regions{I};
	  	for i=1:Bndred_regions{I}
			  Regions_disp{i} = sprintf('%d', i);
	  	end
	else
	  for i=1:Bndred_regions{I}
		  if Regions{I}{i}.Private.Active
			  k = k+1;
			  Regions_disp{k} = sprintf('%d', i);
		  end
	  end
	end
	
	if k > 0
		Region_right{I} = base2dec(Regions_disp{1}, 10);		% to correspond
		Choice_right = uicontrol('Parent', New_wind);
		Call_back_right = ...
	   	sprintf('Segment_demo(''Right'', %18.16f, %d)', Choice_right, I);
		set(Choice_right, 'Style', 'Popup', 'String', Regions_disp, ...
	   	'Units', 'Normalized', 'Position', [0.55 0.5 0.45 0.5], ...
	   	'Callback', Call_back_right);
		Ok_button = uicontrol('Parent', New_wind, ...
	      'String', 'OK', 'Style', 'Pushbutton', ...
	      'Units', 'Normalized', 'Position', [0.1 0 0.3 0.4]);
	end
	
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Cancel operation', 0, I);
	Cancel_button = uicontrol('Parent', New_wind, ...
	   'String', 'Cancel', 'Style', 'Pushbutton', 'Callback', Callback, ...
	   'Units', 'Normalized', 'Position', [0.6 0 0.3 0.4]);
else
	Interactive = 0;
end
