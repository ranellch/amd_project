function Segment_demo (Action, Arguments, varargin)

global All_vars Biomed_on;
if size(All_vars, 2) > 0
   eval (['global ', All_vars]);
end
% regions are represented as structures of:
% private chars:
	% Number - region number
	% Color - the original color to draw the region
	% Line - the actual points as a line object
	% Active - whether it was merged into another region
	% From - which regions it was obtained from (by merging or cutting)
% public chars:
	% Boundary (Boundary) given as set of points
	% Area - total area of the regions, since computed anyway
	% Inner point - telling where the interior of region is (Inner_pts)
	% Shifts - a matrix of size 2 by 2 giving min, max x and y vals for boundary
	% Region_matr - the filled with pixels boundary for various operations
% user defined chars:

if nargin < 1
	warning off;
  	Common_vars =[' Gray_image Image Luv_image Image_is_gray ', ...
      ' Region_colors Bndred_regions Curr_pt Curr_pt_line ',...
      ' Slices Centers Store_mouse_pts ', ...
      ' Regions Region_menu_added Min_region_size ', ...
      ' Region_menu Main_figure Main_axis Marker_size ', ...
		' Region_left Region_right Show_all_regions ', ...
		' Instance Active_instances Biomed_on '];

	Biomed_vars = [' Amnt_rot Window_regs_chosen Window1 Window2 '];

	All_vars = [Common_vars, Biomed_vars];
	eval (['global ', All_vars]);
	Action = 'Initialize';
end

if strcmp(Action, 'Initialize')
   if nargin < 2  							% the very first call to it
      Msg_box_hndl = msgbox('Welcome to the system ...', 'Welcome');
      Child = get(Msg_box_hndl, 'Children');			% the OK button
      set(Child(length(Child)), 'Style', 'Text',    'String', '');
      Image_menu = uimenu(Msg_box_hndl, 'Label','&Image');
      uimenu(Image_menu, 'Label', '&Open...', ...
         'Callback', 'close; Segment_demo(''Read image'')', 'Accelerator', 'O');
      uimenu(Image_menu, 'Label', '&Quit', ...
         'Callback', 'close', 'Separator','on', 'Accelerator', 'Q');
		Screen_size = get(0, 'ScreenSize');
		Marker_size = round(max(Screen_size)/200);
   else
		I = varargin{length(varargin)};		% last argument always
      if length(size(Arguments)) == 3		% color image
         Image_is_gray{I} = 0;
         Image{I} = Arguments;
      else
         Image_is_gray{I} = 1;
         Image{I} = Arguments;
         Gray_image{I} = double(Arguments);
      end

		if not(varargin{1})		% does not need new window
			Kids = get(Main_axis{I}, 'Children');
			for i=1:length(Kids)
				if strcmp(get(Kids(i), 'Type'), 'line')
					set(Kids(i), 'XData', 0, 'YData', 0, 'Visible', 'off');
				end
			end
			Segment_demo('Refresh image', 0, I);
		end

      Regions{I} = {};
		Bndred_regions{I} = 0;
      Region_left{I} = 0;  Region_right{I} = 0;
      Store_mouse_pts{I} = 0; Curr_pt_line{I} = 0;
		Show_all_regions{I} = 0;	% will show only active regions by default

		% Biomed vars go here
		if Instance == 1
			Window_regs_chosen = 0;
		end
     	Amnt_rot{I} = 8;

      % the list of colors
      Region_colors{1, 1} = 'magenta';
      Region_colors{1, 2} = 'yellow';
      Region_colors{1, 3} = 'green';
      Region_colors{1, 4} = 'red';
      Region_colors{1, 5} = 'cyan';
      Region_colors{1, 6} = 'blue';
      Region_colors{1, 7} = 'black';

		if varargin{1}		% needs new window
      	Region_menu_added{I} = 0;
			ButtonDown = sprintf('Segment_demo(''%s'',%d,%d)', 'Down', 0, I);
			CloseReq = sprintf('Segment_demo(''%s'',%d,%d)', 'Exit', 0, I);
	      set(gcf, 'WindowButtonDownFcn', ButtonDown, 'MenuBar', 'none', ...
				'CloseRequestFcn', CloseReq);
	      Main_figure{I} = gcf;
			Main_axis{I} = gca;
	      Image_menu = uimenu('Label','&Image');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Read image', 0, I);
	      uimenu(Image_menu, 'Label', '&Open...', ...
	         'Callback', Callback, 'Accelerator', 'O');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Smooth prompt', 0, I);
	      uimenu(Image_menu, 'Label', 's&Mooth...', ...
	         'Callback', Callback, 'Accelerator', 'M');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Segment prompt', 0, I);
	      uimenu(Image_menu, 'Label', 'se&Gment...', ...
	         'Callback', Callback, 'Accelerator', 'G');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Crop', 0, I);
	      uimenu(Image_menu, 'Label', '&Crop...', ...
	         'Callback', Callback, 'Accelerator', 'C');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Refresh image', 0, I);
	      uimenu(Image_menu, 'Label', 'r&Efresh!', ...
	         'Callback', Callback, 'Accelerator', 'E');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Label prompt', 0, I);
	      uimenu(Image_menu, 'Label', 'l&abel', ...
	         'Callback', Callback, 'Accelerator', 'A');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Save image', 0, I);
	      uimenu(Image_menu, 'Label', '&Save as...', ...
	         'Callback', Callback, 'Accelerator', 'S');
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Exit', 0, I);
	      uimenu(Image_menu, 'Label', '&Quit', ...
	         'Callback', Callback, 'Separator','on', 'Accelerator', 'Q');
			Segment_demo('Show image', 1, I);		% needs window size setting
		else
			Segment_demo('Show image', 0, I);		% no window size setting
		end
   end
end


%-----------------------------------------
% exiting if desired, after warning
if strcmp(Action, 'Exit')
	I = varargin{length(varargin)};		% last argument always
   set(Main_figure{I}, 'CloseRequestFcn', 'closereq');
   close;
	Active_instances = Active_instances-1;
	if Active_instances == 0
		eval (['clear global ', All_vars]);
	end

%-----------------------------------------
% keeping track of the pixel clicked onto by mouse
elseif strcmp(Action, 'Down')	% request to pick region follows
	I = varargin{length(varargin)};		% last argument always
  	Curr_pt_get{I} = get(gca, 'CurrentPoint');
   Curr_pt_get{I} = round(Curr_pt_get{I}(1, 1:2));
   Curr_pt_get{I} = [Curr_pt_get{I}(2); Curr_pt_get{I}(1)]; % switching x and y
   if Store_mouse_pts{I}
      Curr_pt{I} = [Curr_pt{I}, Curr_pt_get{I}];
   else
      Curr_pt{I} = Curr_pt_get{I};
   end
   if Curr_pt_line{I}
      set(Curr_pt_line{I}, 'XData',Curr_pt{I}(2, :), 'YData',Curr_pt{I}(1, :));
   else
      Curr_pt_line{I} = ...
			line('XData', Curr_pt{I}(2, :), 'YData', Curr_pt{I}(1, :), ...
         'Marker', '.', 'Color', 'yellow', 'EraseMode', 'none');
   end
 
 
%-----------------------------------------
% segmenting the image into a number of subregions by the subroutine
elseif strcmp(Action, 'Segment prompt')
	I = varargin{length(varargin)};		% last argument always
   Prompt  = {...
		'Window size (small window => small variation)', ...
		'Color components to use (fewer => quicker)', ...
      'Color group size (small size => fewer colors left)', ...
      'Min region size (small size => more small regions)', ...
      'Would you like to see separate layers?'};
	if Image_is_gray{I}
		Default = {20, 1, 200, 20, 'No'};
	 else
     	Default = {30, 2, 200, 20, 'No'};
	end
   Title = 'Segmentation parameters';
   Line_number  = 1;
   Segment_input  = My_inputdlg(Prompt, Title, Line_number, Default);
   if size(Segment_input, 2) > 0
      Segment_demo ('Initialize', Image{I}, 0, I); 	% does not need new wind
      Segment_demo ('Segment', Segment_input, I);
   end


%-----------------------------------------
% segmenting the image into a number of subregions by the subroutine
elseif strcmp(Action, 'Segment')
	I = varargin{length(varargin)};		% last argument always
   Segment_input = Arguments;
   Window_radius = base2dec(Segment_input{1}, 10);
	Components = base2dec(Segment_input{2}, 10);
	% Components = round(max(Components, 2));		% for a while
   Color_group = base2dec(Segment_input{3}, 10);
   Min_region_size{I} = base2dec(Segment_input{4}, 10);
	Plot_slices = length(findstr(lower(Segment_input{5}), 'y'));
   if Image_is_gray{I}
      [Segmented, Centers] = ...
         Gray_segment (Gray_image{I}, Window_radius, Color_group);
   else
      Luv_image{I} = Rgb_to_luv(Image{I}, 'Image');
      Gray_image{I} = squeeze(Luv_image{I}(:, :, 1));
		Lhs = '[Segmented, Centers] = ';
		Rhs = [sprintf('Color_segment_svd%d', Components), ...
			'(Luv_image{I}, Window_radius, Color_group);'];
		eval([Lhs, Rhs]);
   end

   Segments = size(Centers, 2);
   Slices{I} = zeros(size(Gray_image{I}));

   if Plot_slices
      figure;	% plotting the resulting regions
      Square_side = ceil(sqrt(Segments));
   end

   for i=1:Segments
      Slice = (Segmented == i);
      % some image processing - taken from morphology file
      Slice = bwmorph(Slice, 'majority');
      Slice = (Slice == 0);	% negation
      Slice = bwmorph(Slice, 'majority');
      Slice = (Slice == 0);	% negation
      % Slice = bwmorph(Slice, 'thicken', 2);    % no thickening for a while
      Slices{I}(:, :, i) = bwlabel(Slice);
      if Plot_slices
         subplot(Square_side, Square_side, i);
         image((Slices{I}(:, :, i)>0)*255); axis off;
         colormap(gray(255));
      end
   end
	if Plot_slices
   	figure(Main_figure{I});
	end

  	% appending the new submenu
	if not(Region_menu_added{I})
		Region_menu{I} = uimenu('Label', '&Region');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Find boundary', 0, I);
		uimenu(Region_menu{I}, 'Label', '&Find boundary', ...
			'Callback', Callback, 'Accelerator', 'F');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Select left region', 0, I);
		uimenu(Region_menu{I}, 'Label', '(un)select &1-st region', 'Enable', 'off', ...
            'Callback', Callback, 'Accelerator', '1');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Select right region', 0, I);
		uimenu(Region_menu{I}, 'Label', '(un)select &2-nd region', 'Enable', 'off', ...
            'Callback', Callback, 'Accelerator', '2');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)','Save boundary prompt',0,I);
		uimenu(Region_menu{I}, 'Label', 'sa&Ve as...', 'Enable', 'off', ...
			'Callback', Callback, 'Accelerator', 'V');
		Compare_menu = uimenu(Region_menu{I}, 'Label', '&Compare to...', ...
			'Enable', 'off');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', ...
			'Compare disk regions prompt', 0, I);
		uimenu(Compare_menu, 'Label', '&Disk region...', ...
			'Callback', Callback, 'Accelerator', 'D');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', ...
			'Compare image regions prompt', 0, I);
		uimenu(Compare_menu, 'Label', '&Image region...', ...
			'Callback', Callback, 'Accelerator', 'I');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', ...
			'Compare window regions prompt', 0, I);
		uimenu(Compare_menu, 'Label', '&Window region...', ...
			'Callback', Callback, 'Accelerator', 'W');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Merge prompt', 0, I);
		uimenu(Region_menu{I}, 'Label', 'me&Rge...', 'Enable', 'off', ...
			'Callback', Callback, 'Accelerator', 'R');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Cut prompt', 0, I);
		uimenu(Region_menu{I}, 'Label', 'c&Ut...', 'Enable', 'off', ...
			'Callback', Callback, 'Accelerator', 'U');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', ...
			'Intensity 3-d prompt', 0, I);
		uimenu(Region_menu{I},'Label', 'intensity &3-d...', 'Enable','off', ...
			'Callback', Callback, 'Accelerator', '3');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', ...
			'Background region prompt',0, I);
		uimenu(Region_menu{I}, 'Label', 'bac&Kground...', 'Enable', 'off', ...
            'Callback', Callback, 'Accelerator', 'K');
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Color prompt', 0, I);
		uimenu(Region_menu{I}, 'Label', 'co&Lor...', 'Enable', 'off', ...
            'Callback', Callback, 'Accelerator', 'L');
		Callback=sprintf('global Marker_size; Marker_size = Marker_size + 2;');
		uimenu(Region_menu{I}, 'Label', 'Thicken next line', 'Enable', 'off', ...
			'Callback', Callback);
		Callback=sprintf('global Marker_size; Marker_size = Marker_size - 2;');
		uimenu(Region_menu{I}, 'Label', 'Thin next line', 'Enable', 'off', ...
			'Callback', Callback);
		Region_menu_added{I} = 1;
	end


%-----------------------------------------
elseif strcmp(Action, 'Crop')
	I = varargin{length(varargin)};		% last argument always
	msgbox('Please crop a subregion', 'Cropping');
   waitforbuttonpress;
   Point1 = get(gca,'CurrentPoint');    % button down detected
   Final_rect = rbbox;                  % return Figure units
   Point2 = get(gca,'CurrentPoint');    % button up detected
   Point1 = round(Point1(1,1:2));       % extract x and y
   Point2 = round(Point2(1,1:2));
   P1 = min(Point1,Point2);             % calculate locations
   Offset = abs(Point1-Point2);         % and dimensions
   Rect_x = [P1(1) P1(1)+Offset(1) P1(1)+Offset(1) P1(1) P1(1)];
   Rect_y = [P1(2) P1(2) P1(2)+Offset(2) P1(2)+Offset(2) P1(2)];
   hold on;
   axis manual;
   plot(Rect_x, Rect_y);

   Button = questdlg('Is it suitable?', 'Crop/Undo cropping','Yes','No','Yes');
   if strcmp(Button,'Yes')
      Left_x = min(Rect_y);  Right_x = max(Rect_y);	% again shift
      Low_y = min(Rect_x);  High_y = max(Rect_x);		% again shift
      if Image_is_gray{I}
         Image_cropped = Gray_image{I}(Left_x:Right_x, Low_y:High_y);
      else
         Image_cropped = Image{I}(Left_x:Right_x, Low_y:High_y, :);
      end

		% creating a window for the newly cropped image
		figure;							% creating one more window
		set (gcf, 'Name', [get(Main_figure{I}, 'Name'), ' cropped']);
		if length(Instance) > 0	% was defined
			Instance = Instance+1;
			Active_instances = Active_instances+1;
		 else
		 	Instance = 1;
			Active_instances = 1;
		end
   	Segment_demo ('Initialize', Image_cropped, 1, Instance);	%needs new window
	else
		Segment_demo('Refresh image', 0, I);
   end   


%-----------------------------------------
elseif strcmp(Action, 'Smooth prompt')
	I = varargin{length(varargin)};		% last argument always
   Scr_sz = get(0, 'ScreenSize');
   New_wind = dialog('Name', 'Which filter to use?', 'Position', ...
      [Scr_sz(3)*0.3 Scr_sz(4)*0.4 Scr_sz(3)*0.3 Scr_sz(4)*0.1]);
   Choice = uicontrol('Parent', New_wind);
   Callback = sprintf('Segment_demo(''Smooth'', %18.16f, %d)', Choice, I);
   set(Choice, 'Style', 'Popup', ...
      'String', {'Circle-5', 'Symlet', 'Avg-3'}, ...
      'Units', 'Normalized', 'Position', [0 0.5 1 0.5]);
   Cancel_button = uicontrol('Parent', New_wind, ...
      'String', 'Cancel', 'Style', 'Pushbutton', 'Callback', 'close', ...
      'Units', 'Normalized', 'Position', [0.6 0.3 0.3 0.4]);
   Ok_button = uicontrol('Parent', New_wind, ...
      'String', 'OK', 'Style', 'Pushbutton', 'Callback', Callback, ...
      'Units', 'Normalized', 'Position', [0.1 0.3 0.3 0.4]);


%----------------------------------------
elseif strcmp(Action, 'Smooth')
	I = varargin{length(varargin)};		% last argument always
	Choice = get(Arguments, 'Value');
	close;			% closing the prompt window
	switch Choice
	case 2
		Filter = 'Symlets';
	case 3
		Filter = ones(3);
		Filter = Filter/sum(sum(Filter));
	case 1
		Filter = ones(5);
		Filter(1:2, 1) = zeros(2, 1); Filter(4:5, 1) = zeros(2, 1);
		Filter(1:2, 5) = zeros(2, 1); Filter(4:5, 5) = zeros(2, 1);
		Filter(1, 2) = 0; Filter(5, 2) = 0;
		Filter(2, 5) = 0; Filter(5, 4) = 0;
		Filter = Filter/sum(sum(Filter));
	otherwise
		Filter = 1;
	end
	if size(Filter, 2) > 1
		if strcmp(Filter, 'Symlets')
			if Image_is_gray{I}
				Image_filtered = Smooth_wv(Gray_image{I});
			else
				for i=1:3
					Image_filtered(:, :, i) = Smooth_wv(Image{I}(:, :, i));
				end
			end
	 	else
			if Image_is_gray{I}
				Image_filtered = filter2(Filter, Gray_image{I});
			else
				for i=1:3
					Image_filtered(:, :, i) = filter2(Filter, Image{I}(:, :, i));
				end
			end
		end
		Segment_demo ('Initialize', Image_filtered, 0, I);	% no new window
	end


%-----------------------------------------
% now saves both in low-quality and high quality formats in jpeg/tif/bmp and
% in eps format with a standard size
elseif strcmp(Action, 'Save image')
	I = varargin{length(varargin)};		% last argument always
   % Filter = '*.jpeg; *.jpg; *.tif; *.tiff; *.bmp; *.eps; *.ps';
   Filter = '*.jpeg; *.jpg; *.tif; *.bmp; *.eps';
   [File_name, Path_name] = uiputfile(Filter, 'Save to file ...');
   [Screen, Screen_map] = capture(Main_figure{I});
   % splitting file name into extension and file itself
   for i=length(File_name):-1:1
      if File_name(i) == '.'
         File_type = File_name(i+1:length(File_name));
			File_name = File_name(1:i-1);
         break;
      end
   end
   
   if File_name(1) > 0
		if (strcmp(File_type, 'jpeg') | strcmp(File_type, 'jpg'))
			% low-level file first
      	imwrite(Screen, Screen_map, [Path_name, File_name, '_low.', File_type], ...
				File_type, 'Quality', 80);
			print_string = sprintf('%s %s', 'print -djpeg ', ...
				[Path_name, File_name, '_high.', File_type]);
			eval(print_string);
			msgbox(['Image was saved in ',  File_name, '_low.', File_type, ...
				'  and  ',  File_name, '_high.', File_type], 'Files saved');
		end
		if (strcmp(File_type, 'tiff') | strcmp(File_type, 'tif'))
			% low-level file first
      	imwrite(Screen, Screen_map, [Path_name, File_name, '_low.', File_type], ...
				File_type);
			print_string = sprintf('%s %s', 'print -dtiff ', ...
				[Path_name, File_name, '_high.', File_type]);
			eval(print_string);
			msgbox(['Image was saved in ',  File_name, '_low.', File_type, ...
				'  and  ',  File_name, '_high.', File_type], 'Files saved');
		end
		if strcmp(File_type, 'bmp')
			% low-level file first
      	imwrite(Screen, Screen_map, [Path_name, File_name, '.', File_type], ...
				File_type);
			print_string = sprintf('%s %s', 'print -djpeg ', ...
				[Path_name, File_name, '.jpg']);
			eval(print_string);
			msgbox(['Image was saved in ',  File_name, '.', File_type, ...
				'  and  ',  File_name, '.jpg'], 'Files saved');
		end
		if (strcmp(File_type, 'eps') | strcmp(File_type, 'ps'))
			print_string = sprintf('%s %s', 'print -depsc -loose ', ...
				[Path_name, File_name, '.', File_type]);
			eval(print_string);
			msgbox(['Image was saved in ',  File_name, '.', File_type], ...
				'Files saved');
		end
   end

 
%-----------------------------------------   
elseif strcmp(Action, 'Read image')
   Filter = '*.jpeg; *.jpg; *.tif; *.tiff; *.bmp';
   [File_name, Path_name] = uigetfile(Filter, 'Open file');
	Image_name = File_name;
   File_name = [Path_name, File_name];
   if File_name(1) > 0						% not zeros there
      [Im_read, Map] = imread(File_name);
		if length(Map) > 0		% not gray or RGB, but could be made such
			Im_read = ind2rgb(Im_read, Map);
			Im_read = 256*Im_read;
		end
		Im_read = double(Im_read);
      if length(size(Im_read)) == 3		% color image
			for i=1:3
			  Img(:,:,i) = min(Im_read(:,:,i)+ones(size(Im_read(:,:,i))), ...
					255*ones(size(Im_read(:,:,i))));
			end
		else
         Img = min(Im_read+ones(size(Im_read)),255*ones(size(Im_read)));
		end
		figure;							% creating one more window
		set (gcf, 'Name', Image_name);
		if length(Instance) > 0	% was defined
			Instance = Instance+1;
			Active_instances = Active_instances+1;
		 else
		 	Instance = 1;
			Active_instances = 1;
		end
      Segment_demo('Initialize', Img, 1, Instance);		% needs new window
   end
 
 
%-----------------------------------------
elseif strcmp(Action, 'Refresh image')
	I = varargin{length(varargin)};		% last argument always
	if length(Curr_pt_line) >= I
		if Curr_pt_line{I} > 0
			set(Curr_pt_line{I}, 'EraseMode', 'normal');
			set(Curr_pt_line{I}, 'Visible', 'off');
			set(Curr_pt_line{I}, 'Visible', 'on');
			set(Curr_pt_line{I}, 'EraseMode', 'none');
		end
	end

	% deleting rectangles if present - they have few points
	Kids = get(Main_axis{I}, 'Children');
	for i=1:length(Kids)
		if strcmp(get(Kids(i), 'type'), 'line') & ...
				length(get(Kids(i), 'XData')) == 5	% rectangle
			set(Kids(i), 'XData', 0, 'YData', 0, 'Visible', 'off');
		end
	end


%-----------------------------------------
% labeling the image at a chosen place
elseif strcmp(Action, 'Label prompt')
	I = varargin{length(varargin)};		% last argument always
	% determining whether near an existing label
  	Curr_pt_local = get(gca, 'CurrentPoint');
  	Curr_pt_local = round(Curr_pt_local(1, 1:2));
	kids = get(gca, 'children');
	for i=1:length(kids)
		if strcmp(get(kids(i), 'type'), 'text') & ...
				strcmp(get(kids(i), 'visible'), 'on') & ...
				length(get(kids(i), 'string')) > 0
			text_pos = get(kids(i), 'position');
			text_pos = text_pos(1:2);
			if norm(Curr_pt_local-text_pos)<8
				set(kids(i), 'editing', 'on');
				return;
			end
		end
	end

   Prompt  = {'Label', 'Font size', 'Font type', 'Font color', 'Rotated'};
	Default = {'Region ', 10, 'Courier', 'black', 0};
   Title = 'Labeling image';
   Line_number  = 1;
   Label_input  = My_inputdlg(Prompt, Title, Line_number, Default);
   if size(Label_input, 2) > 0
		new_text = text(Curr_pt_local(1), Curr_pt_local(2), Label_input{1});
		set(new_text, 'fontsize', base2dec(Label_input{2}, 10), ...
			'fontname', Label_input{3}, 'color', Label_input{4}, ...
			'rotation',  base2dec(Label_input{5}, 10));
   	Button = questdlg('Is it suitable?', 'Labeling', 'Yes', 'No', 'Yes');
   	if strcmp(Button, 'No')
			set(new_text, 'visible', 'off');
		end
   end

%-----------------------------------------
elseif strcmp(Action, 'Show image')			% for internal purposes only
	I = varargin{length(varargin)};			% last argument always
	Rows = size(Image{I}, 1);
	Cols = size(Image{I}, 2);
	if Arguments									% needs size setting
	   Max_rc = max(Rows, Cols);
	   Scr_sz = get(0, 'ScreenSize');
		% "tiling" the images on the screen into 3 by 4 grid
		Grid_v = mod(floor((I-1)/4), 3);		% finding row
		Grid_h = mod(I+3, 4);					% finding column
	   New_position(1:2) = [Scr_sz(3)*(0.04+0.24*Grid_h) ...
									Scr_sz(4)*(0.08+0.31*Grid_v)];
	   New_position(3) = Scr_sz(3)*0.22*Cols/Max_rc;
	   New_position(4) = Scr_sz(4)*0.22*Rows/Max_rc;
	   set(Main_figure{I}, 'Position', New_position);
	end
	Axis_children = get(Main_axis{I}, 'Children');
	Image_handle = 0;
	for i=length(Axis_children):-1:1
		if strcmp(get(Axis_children(i), 'Type'), 'image')
			Image_handle = Axis_children(i);
			break;
		end
	end
   if Image_is_gray{I}
		if not(Image_handle)
			Image_handle = image(Gray_image{I});
			set(Image_handle, 'Parent', Main_axis{I});
			axis([1, Cols, 1, Rows]);
		else
			set(Image_handle, 'CData', Gray_image{I});
			axis([1, Cols, 1, Rows]);
		end
		colormap(gray(255));
   else
		if not(Image_handle)
			Image_handle = image(uint8(floor(double(Image{I}))));	% no maps
			set(Image_handle, 'Parent', Main_axis{I});
			axis([1, Cols, 1, Rows]);
		else
			set(Image_handle, 'CData', uint8(floor(double(Image{I}))));
			axis([1, Cols, 1, Rows]);
		end
   end
  	set(Main_axis{I}, 'Position', [0 0 1 1], 'XTick', [], 'YTick', []);

 
%----------------------------------------
elseif strcmp(Action, 'Enable region')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% call from interactive input
		close;				% prompt
		Arguments = Region_left{I};
		Region_left{I} = 0;
	end
	Regions{I}{Arguments}.Private.Active = 1;
  	Segment_demo('Draw boundary', Arguments, I);


%-----------------------------------------
elseif strcmp(Action, 'Background region prompt')
	I = varargin{length(varargin)};		% last argument always
	Operation_prompt;		% the common piece
	if Interactive 
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Background region', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Background region', 1, I);
		eval(Callback);
	end


%----------------------------------------
elseif strcmp(Action, 'Background region')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% from interactive
		close;	% prompt
	end
	[Rows, Cols] = size(Regions{I}{Region_left{I}}.Public.Region_matr);
	Shift = Regions{I}{Region_left{I}}.Public.Shifts(1:2, 1);
	if Image_is_gray{I}
		for i=1:Rows
	      for j=1:Cols
	         if Regions{I}{Region_left{I}}.Public.Region_matr(i, j)
					Image{I}(i+Shift(1)-1, j+Shift(2)-1) = 0;
	            Gray_image{I}(i+Shift(1)-1, j+Shift(2)-1) = 0;
				end
			end
		end
	else
		for i=1:Rows
	      for j=1:Cols
	         if Regions{I}{Region_left{I}}.Public.Region_matr(i, j)
					Image{I}(i+Shift(1)-1, j+Shift(2)-1, :) = [0, 0, 0];
				end
			end
		end
	end
   Segment_demo('Draw boundary', Region_left{I},  'none', I);
   Region_left{I} = 0;
  	Segment_demo('Show image', 0, I);


%-----------------------------------------
elseif strcmp(Action, 'Color prompt')
	I = varargin{length(varargin)};		% last argument always
	Operation_prompt;		% the common piece
	if Interactive 
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Region color prompt', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Region color prompt', 1, I);
		eval(Callback);
	end


%-----------------------------------------
elseif strcmp(Action, 'Region color prompt')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% from interactive
		close;	% prompt
	end
   Scr_sz = get(0, 'ScreenSize');
   New_wind = dialog('Name', 'Choose region color', 'Position', ...
      [Scr_sz(3)*0.3 Scr_sz(4)*0.4 Scr_sz(3)*0.3 Scr_sz(4)*0.1]);
   set(New_wind, 'WindowStyle', 'normal');
	Choice_color = uicontrol('Parent', New_wind);
	set(Choice_color, 'Style', 'Popup', 'String', Region_colors, ...
		  	'Units', 'Normalized', 'Position', [0 0.5 0.45 0.5]);
   Cancel_button = uicontrol('Parent', New_wind, ...
      'String', 'Cancel', 'Style', 'Pushbutton', 'Callback', 'close', ...
      'Units', 'Normalized', 'Position', [0.6 0.3 0.3 0.4]);
	Callback=sprintf('Segment_demo(''%s'',%18.16f,%d)', 'Region color', Choice_color, I);
   Ok_button = uicontrol('Parent', New_wind, ...
      'String', 'OK', 'Style', 'Pushbutton', 'Callback', Callback, ...
      'Units', 'Normalized', 'Position', [0.1 0.3 0.3 0.4]);


%-----------------------------------------
elseif strcmp(Action, 'Region color')
	I = varargin{length(varargin)};		% last argument always
	Index_color = get(Arguments, 'Value');
	Index_string = get(Arguments, 'String');
	close;	% input window
	Regions{I}{Region_left{I}}.Private.Color = Index_string{Index_color};
	Segment_demo('Draw boundary', Region_left{I}, I);
	Region_left{I} = 0;


%-----------------------------------------
elseif strcmp(Action, 'Select left region')
	I = varargin{length(varargin)};		% last argument always
  	Curr_pt_local = get(gca, 'CurrentPoint');
  	Curr_pt_local = round(Curr_pt_local(1, 1:2));
	Curr_pt_local = Curr_pt_local(2:-1:1);
	for i=Bndred_regions{I}:-1:1
		Min_x = Regions{I}{i}.Public.Shifts(1, 1);
		Min_y = Regions{I}{i}.Public.Shifts(2, 1);
		Max_x = Regions{I}{i}.Public.Shifts(1, 2);
		Max_y = Regions{I}{i}.Public.Shifts(2, 2);
		if Curr_pt_local(1) >= Min_x & Curr_pt_local(1) <= Max_x
		if Curr_pt_local(2) >= Min_y & Curr_pt_local(2) <= Max_y
			if Regions{I}{i}.Public.Region_matr(...
				Curr_pt_local(1)-Min_x+1, Curr_pt_local(2)-Min_y+1) > 0
				% then the region has been found
   			if Region_left{I}									% was assigned some value
      			if not(Region_left{I} == Region_right{I})
         			Segment_demo('Draw boundary', Region_left{I}, I);
      			end
   			end
				if Region_left{I} == i		% this was selected, now is deselected
					Region_left{I} = 0;
				else
   				Region_left{I} = i;
   				Segment_demo('Draw boundary', Region_left{I}, 'white', I);
				end
				break;
			end
		end
		end
	end


%-----------------------------------------
elseif strcmp(Action, 'Select right region')
	I = varargin{length(varargin)};		% last argument always
  	Curr_pt_local = get(gca, 'CurrentPoint');
  	Curr_pt_local = round(Curr_pt_local(1, 1:2));
	Curr_pt_local = Curr_pt_local(2:-1:1);
	for i=Bndred_regions{I}:-1:1
		Min_x = Regions{I}{i}.Public.Shifts(1, 1);
		Min_y = Regions{I}{i}.Public.Shifts(2, 1);
		Max_x = Regions{I}{i}.Public.Shifts(1, 2);
		Max_y = Regions{I}{i}.Public.Shifts(2, 2);
		if Curr_pt_local(1) >= Min_x & Curr_pt_local(1) <= Max_x
		if Curr_pt_local(2) >= Min_y & Curr_pt_local(2) <= Max_y
			if Regions{I}{i}.Public.Region_matr(...
				Curr_pt_local(1)-Min_x+1, Curr_pt_local(2)-Min_y+1) > 0
				% then the region has been found
   			if Region_right{I}									% was assigned some value
      			if not(Region_left{I} == Region_right{I})
         			Segment_demo('Draw boundary', Region_right{I}, I);
      			end
   			end
				if Region_right{I} == i		% this was selected, now is deselected
					Region_right{I} = 0;
				else
   				Region_right{I} = i;
   				Segment_demo('Draw boundary', Region_right{I}, 'white', I);
				end
				break;
			end
		end
		end
	end

%----------------------------------------
elseif strcmp(Action, 'Disable region')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% call from interactive input
		close;			% prompt
		Arguments = Region_left{I};
		Region_left{I} = 0;
	end
  	Regions{I}{Arguments}.Private.Active = 0;
  	Segment_demo('Draw boundary', Arguments,  'none', I);
	Segment_demo('Refresh image', 0, I);


%-----------------------------------------
elseif strcmp(Action, 'Find boundary')
	I = varargin{length(varargin)};		% last argument always
 	Rows = size(Image{I}, 1);
  	Cols = size(Image{I}, 2);
  	if length(Curr_pt{I}) > 0	% was defined
     if ((Curr_pt{I}(1) > 0) & (Curr_pt{I}(2) > 0) & ...
           (Curr_pt{I}(1) < Rows) & (Curr_pt{I}(2) < Cols))
        for i=1:size(Slices{I}, 3)
           if Slices{I}(Curr_pt{I}(1), Curr_pt{I}(2), i) > 0	% in this slice
              [Boundary, Area] = Extract_region_reg(Slices{I}(:, :, i) == ...
                 Slices{I}(Curr_pt{I}(1),Curr_pt{I}(2), i), Min_region_size{I});
              break;
           end
        end
     end
     
     if exist('Boundary', 'var')
     if size(Boundary, 2) > 1
     		Bndred_regions{I} = Bndred_regions{I}+1;
        	Regions{I}{Bndred_regions{I}}.Private.Number = Bndred_regions{I};
        	Regions{I}{Bndred_regions{I}}.Public.Boundary = Boundary;
        	Min_x = min(Boundary(1, :));  Max_x = max(Boundary(1, :));
        	Min_y = min(Boundary(2, :));  Max_y = max(Boundary(2, :));
        	Regions{I}{Bndred_regions{I}}.Public.Shifts = ...
		  		[Min_x, Max_x; Min_y, Max_y];
        	Regions{I}{Bndred_regions{I}}.Public.Inner_pts = ...
		  		[Curr_pt{I}(1); Curr_pt{I}(2)];
		   Regions{I}{Bndred_regions{I}}.Public.Region_matr = ...
				Region_matrix(Regions{I}{Bndred_regions{I}}.Public);
        	Regions{I}{Bndred_regions{I}}.Private.Color = ...
         	Region_colors{1, 1+rem(Bndred_regions{I}-1, size(Region_colors, 2))};
        % Regions{I}{Bndred_regions{I}}.Private.Color = ...
        %   global_color;
        	Regions{I}{Bndred_regions{I}}.Private.Line = 0;
		  	Regions{I}{Bndred_regions{I}}.Private.From = [];
		  % setting up variables for region info values
        	Regions{I}{Bndred_regions{I}}.Public.Area = -99;
        	Regions{I}{Bndred_regions{I}}.Public.Volume= -99;
        	Regions{I}{Bndred_regions{I}}.Public.Avg_intensity = -99;
        	Menu_children = get(Region_menu{I}, 'Children');
        	for i=1:length(Menu_children)
           	set (Menu_children(i), 'Enable', 'on');
        	end
        	Segment_demo('Draw boundary first time', Bndred_regions{I}, I);
        	Segment_demo('Enable region', Bndred_regions{I}, I);
    end
    end
  end
  
  
%-----------------------------------------
elseif strcmp(Action, 'Save boundary prompt')
	I = varargin{length(varargin)};		% last argument always
	Operation_prompt;		% the common piece
	if Interactive 
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Save boundary', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Save boundary', 1, I);
		eval(Callback);
	end


%----------------------------------------
elseif strcmp(Action, 'Save boundary')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% from interactive
		close;	% prompt
	end
   Filter = '*.rgn';
   [File_name, Path_name] = uiputfile(Filter, 'Save to ...');
   if File_name(1) > 0
      File_name = [Path_name, File_name];
      fid = fopen(File_name, 'w');
      fprintf(fid, '%d %d\n', Regions{I}{Region_left{I}}.Public.Inner_pts(1:2));
		fprintf(fid, '%d %d\n', 0, 0);	% the separation for Inner pts
      fprintf (fid, '%d %d\n', Regions{I}{Region_left{I}}.Public.Boundary);
      fclose(fid);
   end
   Segment_demo('Draw boundary', Region_left{I}, I);
   Region_left{I} = 0;
   
   
%-----------------------------------------
elseif strcmp(Action, 'Compare window regions prompt')
	I = varargin{length(varargin)};		% last argument always
	if not(Window_regs_chosen)				% need to open one more window
   	Operation_prompt;						% the common piece
		if Interactive 
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare window regions', 0, I);
			if Ok_button
				set(Ok_button, 'Callback', Callback);
			end
		else
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare window regions', 1, I);
			eval(Callback);
		end
	else
		Operation_prompt_right;
		if Interactive 
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare window regions', 0, I);
			if Ok_button
				set(Ok_button, 'Callback', Callback);
			end
		else
			Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare window regions', 1, I);
			eval(Callback);
		end
	end

%-----------------------------------------
elseif strcmp(Action, 'Compare window regions')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% interactive input
   	close;
	end
	if not(Window_regs_chosen)		% need to open one more window
   	msgbox('Please choose another region', 'Another');
		Window1 = I;
		Window_regs_chosen = 1;
	else
		Window2 = I;
		% computing chars if needed
		if Regions{Window1}{Region_left{Window1}}.Public.Area < 0
			Segment_demo('Intensity 3-d', Region_left{Window1}, Window1);
		end
		if Regions{Window2}{Region_right{Window2}}.Public.Area < 0
			Segment_demo('Intensity 3-d', Region_right{Window2}, Window2);
		end
		[Bdry_dist, Reg_dist] = ...
			Svd_dist_reg(Regions{Window1}{Region_left{Window1}}.Public, ...
				Regions{Window2}{Region_right{Window2}}.Public);
   	Msg = [sprintf('Boundary difference: %6.2f\n\n', Bdry_dist), ...
   		sprintf('Region  difference: %6.2f\n\n', Reg_dist), ...
			sprintf('Areas ratio: %6.2f\n\n', ...
				Regions{Window1}{Region_left{Window1}}.Public.Area/...
				Regions{Window2}{Region_right{Window2}}.Public.Area), ...
			sprintf('Volumes ratio: %6.2f\n\n', ...
				Regions{Window1}{Region_left{Window1}}.Public.Volume/...
				Regions{Window2}{Region_right{Window2}}.Public.Volume), ...
			sprintf('Avg intensities ratio: %6.2f', ...
				Regions{Window1}{Region_left{Window1}}.Public.Avg_intensity/...
				Regions{Window2}{Region_right{Window2}}.Public.Avg_intensity)
			];
		Wind_name = sprintf('%d and %d regions differences and ratios', ...
			Region_left{Window1}, Region_right{Window2});
   	msgbox(Msg, Wind_name);

   	Segment_demo('Draw boundary', Region_left{Window1}, Window1);
   	Segment_demo('Draw boundary', Region_right{Window2}, Window2);
   	Region_left{Window1} = 0; Region_right{Window2} = 0;
		Window_regs_chosen = 0;
	end


%-----------------------------------------
elseif strcmp(Action, 'Compare image regions prompt')
	I = varargin{length(varargin)};		% last argument always
   Operation_prompt;			% the common piece
   Right_button;				% one more button here	if Interactive 
	if Interactive
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare image regions', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare image regions', 1, I);
		eval(Callback);
	end

%-----------------------------------------
elseif strcmp(Action, 'Compare image regions')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0							% interactive call
   	close;	% prompt
   end
	if Region_right{I} ==  0
		return;
	end
	[Bdry_dist, Reg_dist] = ...
		Svd_dist_reg(Regions{I}{Region_left{I}}.Public, ...
			Regions{I}{Region_right{I}}.Public);
	% computing chars if needed
	if Regions{I}{Region_left{I}}.Public.Area < 0
		Segment_demo('Intensity 3-d', Region_left{I}, I);
	end
	if Regions{I}{Region_right{I}}.Public.Area < 0
		Segment_demo('Intensity 3-d', Region_right{I}, I);
	end
	[Bdry_dist, Reg_dist] = ...
		Svd_dist_reg(Regions{I}{Region_left{I}}.Public, ...
			Regions{I}{Region_right{I}}.Public);
  	Msg = [sprintf('Boundary difference: %6.2f\n\n', Bdry_dist), ...
  		sprintf('Region  difference: %6.2f\n\n', Reg_dist), ...
		sprintf('Areas ratio: %6.2f\n\n', ...
			Regions{I}{Region_left{I}}.Public.Area/...
			Regions{I}{Region_right{I}}.Public.Area), ...
		sprintf('Volumes ratio: %6.2f\n\n', ...
			Regions{I}{Region_left{I}}.Public.Volume/...
			Regions{I}{Region_right{I}}.Public.Volume), ...
		sprintf('Avg intensities ratio: %6.2f', ...
			Regions{I}{Region_left{I}}.Public.Avg_intensity/...
			Regions{I}{Region_right{I}}.Public.Avg_intensity)
		];
	Wind_name = sprintf('%d and %d regions differences and ratios', ...
		Region_left{I}, Region_right{I});
  	msgbox(Msg, Wind_name);

   Segment_demo('Draw boundary', Region_left{I}, I);
   Segment_demo('Draw boundary', Region_right{I}, I);
   Region_left{I} = 0; Region_right{I} = 0;


%-----------------------------------------
elseif strcmp(Action, 'Compare disk regions prompt')
	I = varargin{length(varargin)};		% last argument always
   Operation_prompt;			% the common piece
	if Interactive 
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare disk regions', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Compare disk regions', 1, I);
		eval(Callback);
	end

%-----------------------------------------
elseif strcmp(Action, 'Compare disk regions')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% interactive input
   	close;	% prompt
	end
   Filter = '*.rgn';
   [File_name, Path_name] = uigetfile(Filter, 'Compare to ...');
   if File_name(1) > 0
      File_name = [Path_name, File_name];
      fid = fopen(File_name, 'r');
		k = 0;
		Pt_scanned(1:2, 1) = fscanf(fid, '%d', [2, 1]);
		while sum(Pt_scanned) > 0
			k = k+1;
      	Region2.Public.Inner_pts(:, k) = Pt_scanned;
			Pt_scanned(1:2, 1) = fscanf(fid, '%d', [2, 1]);
		end
      Region2.Public.Boundary = fscanf(fid, '%d', [2, inf]);
		Min_x = min(Region2.Public.Boundary(1, :));  
		Max_x = max(Region2.Public.Boundary(1, :));
      Min_y = min(Region2.Public.Boundary(2, :));
		Max_y = max(Region2.Public.Boundary(2, :));
      Region2.Public.Shifts = [Min_x, Max_x; Min_y, Max_y];
      fclose(fid);
      [Bdry_dist, Reg_dist] = ...
			Svd_dist_reg(Regions{I}{Region_left{I}}.Public, Region2.Public);
      Msg = [sprintf('Boundary difference is  %6.2f\n\n', Bdry_dist), ...
      		 sprintf('Region  difference  is  %6.2f', Reg_dist)]; 
      msgbox(Msg, 'Difference');
   end
   Segment_demo('Draw boundary', Region_left{I}, I);
   Region_left{I} = 0;
   
   
%-----------------------------------------
elseif strcmp(Action, 'Intensity 3-d prompt')
	I = varargin{length(varargin)};		% last argument always
   Operation_prompt;									% the common piece
	if Interactive 
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Intensity 3-d', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Intensity 3-d', -1, I);
		eval(Callback);
	end

%-----------------------------------------
elseif strcmp(Action, 'Intensity 3-d')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0							% interactive call
		Region_number = Region_left{I};
   	close;									% prompt
	elseif Arguments == -1					% was selected not by menu
		Region_number = Region_left{I};
	else
		Region_number = Arguments;
	end
   Volume = 0;
	Area = 0;
   [Rows, Cols] = size(Regions{I}{Region_number}.Public.Region_matr);
   To_display = zeros(Cols, Rows);
   Shift = Regions{I}{Region_number}.Public.Shifts(1:2, 1);
   for i=1:Rows
      for j=1:Cols
         if Regions{I}{Region_number}.Public.Region_matr(i, j)
            To_display(j, i) = Gray_image{I}(i+Shift(1)-1, j+Shift(2)-1);
            Volume = Volume+To_display(j, i);
				Area = Area+1;
         end
      end
   end
   Min = min(To_display(find(To_display > 0)));
   To_display = max(To_display, ones(size(To_display))*Min);
	figure;	% (2)
   mesh(To_display);
	set(gca, 'XTick', [], 'YTick', [], 'view', [77, 67]);	% a better viewpoint
	zlabel('Intensity');
	Wind_name = sprintf('Region %d Intensity 3-d', Region_number);
   set(gcf, 'MenuBar', 'none', 'Name', Wind_name);
   Rotate_menu = uimenu('Label','&Rotate');
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Rotate left', 0, I);
   uimenu (Rotate_menu, 'Label', 'Left', ...
      'Callback', Callback, 'Accelerator', 'L');
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Rotate right', 0, I);
   uimenu (Rotate_menu, 'Label', 'Right', ...
      'Callback', Callback, 'Accelerator', 'R');
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Rotate up', 0, I);
   uimenu (Rotate_menu, 'Label', 'Up', ...
      'Callback', Callback, 'Accelerator', 'U');
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Rotate down', 0, I);
   uimenu (Rotate_menu, 'Label', 'Down', ...
      'Callback', Callback, 'Accelerator', 'D');
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Increase rotation', 0, I);
   uimenu (Rotate_menu, 'Label', 'Increase', ...
      'Callback', Callback, 'Accelerator', 'A');
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Decrease rotation', 0, I);
   uimenu (Rotate_menu, 'Label', 'Decrease', ...
      'Callback', Callback, 'Accelerator', 'V');
   
   Max = max(max(To_display));
	
	Regions{I}{Region_number}.Public.Area = Area;		% storing area
   Area_string = sprintf('Region area\t%10.2f', Area);
	Regions{I}{Region_number}.Public.Volume = Volume;	% storing volume
   Volume_string = sprintf('Volume\t%10.2f', Volume); % compute avg intens
	Avg_intensity = Volume/Area;
   Regions{I}{Region_number}.Public.Avg_intensity = Avg_intensity;
   Avg_intensity_string = sprintf('Average intensity\t%10.2f', Avg_intensity);
   Intensity_normed_volume_string = ...
      sprintf('Intensity normalized volume\t%10.2f', Volume/Max);
	
   Values_menu = uimenu('Label', '&Values');
   uimenu (Values_menu, 'Label', Area_string);
   uimenu (Values_menu, 'Label', Volume_string);
   uimenu (Values_menu, 'Label', Avg_intensity_string);
   uimenu (Values_menu, 'Label', Intensity_normed_volume_string);

	if Arguments <= 0		% interactive
   	Segment_demo('Draw boundary', Region_left{I}, I);
   	Region_left{I} = 0;
	end

%-----------------------------------------
elseif strcmp(Action, 'Rotate right')
	I = varargin{length(varargin)};		% last argument always
   Az_el = get(gca, 'View');
   set(gca, 'View', [Az_el(1)-Amnt_rot{I}, Az_el(2)]);

%-----------------------------------------
elseif strcmp(Action, 'Rotate left')
	I = varargin{length(varargin)};		% last argument always
   Az_el = get(gca, 'View');
   set(gca, 'View', [Az_el(1)+Amnt_rot{I}, Az_el(2)]);

%-----------------------------------------
elseif strcmp(Action, 'Rotate up')
	I = varargin{length(varargin)};		% last argument always
   Az_el = get(gca, 'View');
   set(gca, 'View', [Az_el(1), Az_el(2)-Amnt_rot{I}]);

%-----------------------------------------   
elseif strcmp(Action, 'Rotate down')
	I = varargin{length(varargin)};		% last argument always
   Az_el = get(gca, 'View');
   set(gca, 'View', [Az_el(1), Az_el(2)+Amnt_rot{I}]);
 
%-----------------------------------------   
elseif strcmp(Action, 'Increase rotation')
	I = varargin{length(varargin)};		% last argument always
   Amnt_rot{I} = Amnt_rot{I}*2;

%-----------------------------------------   
elseif strcmp(Action, 'Decrease rotation')
	I = varargin{length(varargin)};		% last argument always
   Amnt_rot{I} = Amnt_rot{I}/2;

   
%-----------------------------------------
elseif strcmp(Action, 'Cut prompt')
	I = varargin{length(varargin)};		% last argument always
   Operation_prompt;									% the common piece
	if Interactive 
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Region cut prompt', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Region cut prompt', 1, I);
		eval(Callback);
	end
 
%-----------------------------------------
elseif strcmp(Action, 'Region cut prompt')
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0		% interactive input
   	close;
	end
   Scr_sz = get(0, 'ScreenSize');
   New_wind = dialog('Name', 'Draw cutting line', 'Position', ...
      [Scr_sz(3)*0.3 Scr_sz(4)*0.4 Scr_sz(3)*0.3 Scr_sz(4)*0.1]);
   set(New_wind, 'WindowStyle', 'normal');
   Cancel_button = uicontrol('Parent', New_wind, ...
      'String', 'Cancel', 'Style', 'Pushbutton', 'Callback', 'close', ...
      'Units', 'Normalized', 'Position', [0.6 0.3 0.3 0.4]);
	Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Cut', 0, I);
   Ok_button = uicontrol('Parent', New_wind, ...
      'String', 'OK', 'Style', 'Pushbutton', 'Callback', Callback, ...
      'Units', 'Normalized', 'Position', [0.1 0.3 0.3 0.4]);
   Store_mouse_pts{I} = 1;
   Curr_pt{I}= zeros(2, 0);
 
%-----------------------------------------
elseif strcmp(Action, 'Cut')
	I = varargin{length(varargin)};		% last argument always
   close;											% the dialogue window
   Dense_pts = Fit_spline(Curr_pt{I});
   
   [Bdry{1}, Inner{1}, Bdry{2}, Inner{2}] = ...
      Cut_boundary_reg(Regions{I}{Region_left{I}}.Public, Dense_pts);
   if (size(Bdry{1}, 2) > 1) & (size(Bdry{2}, 2) > 1)		% detected boundaries
      for i=1:2
         Bndred_regions{I} = Bndred_regions{I}+1;
         Regions{I}{Bndred_regions{I}}.Public.Boundary = Bdry{i};
         Regions{I}{Bndred_regions{I}}.Public.Inner_pts = Inner{i};
         Min_x = min(Regions{I}{Bndred_regions{I}}.Public.Boundary(1, :));  
         Max_x = max(Regions{I}{Bndred_regions{I}}.Public.Boundary(1, :));
         Min_y = min(Regions{I}{Bndred_regions{I}}.Public.Boundary(2, :));  
         Max_y = max(Regions{I}{Bndred_regions{I}}.Public.Boundary(2, :));
         Regions{I}{Bndred_regions{I}}.Public.Shifts = ...
				[Min_x, Max_x; Min_y, Max_y];
         Regions{I}{Bndred_regions{I}}.Private.Number = Bndred_regions{I};
		   Regions{I}{Bndred_regions{I}}.Public.Region_matr = ...
				Region_matrix(Regions{I}{Bndred_regions{I}}.Public);
         Regions{I}{Bndred_regions{I}}.Private.Color = ...
            Region_colors{1, 1+rem(Bndred_regions{I}-1,size(Region_colors, 2))};
		   Regions{I}{Bndred_regions{I}}.Private.From = [Region_left{I}];
        	Regions{I}{Bndred_regions{I}}.Public.Area = -99;
        	Regions{I}{Bndred_regions{I}}.Public.Volume= -99;
        	Regions{I}{Bndred_regions{I}}.Public.Avg_intensity = -99;
         Segment_demo('Draw boundary first time', Bndred_regions{I}, I);% Line
			Segment_demo('Enable region', Bndred_regions{I}, I);
      end
		Segment_demo('Disable region', Region_left{I}, I);
   end

   Region_left{I} = 0;
   Store_mouse_pts{I} = 0;
	set(Curr_pt_line{I}, 'EraseMode', 'normal');
	set(Curr_pt_line{I}, 'Visible', 'off');
	Curr_pt_line{I} = 0;
   Segment_demo('Down', 0, I);
	Segment_demo('Refresh', 0, I);
 

% ----------------------------------------- "left" region
elseif strcmp(Action, 'Left')
	I = varargin{length(varargin)};		% last argument always
   Index_left = get(Arguments, 'Value');
   Labels = get(Arguments, 'String');
   Temp_region_left = base2dec(Labels{Index_left}, 10);
   % restoring the old region first
   if Region_left{I}									% was assigned some value
      if not(Region_left{I} == Region_right{I})
         Segment_demo('Draw boundary', Region_left{I}, I);
      end
   end
   Region_left{I} = Temp_region_left;
   Segment_demo('Draw boundary', Region_left{I}, 'white', I);
   
 
%-----------------------------------------   
% "right" region
elseif strcmp(Action, 'Right')
	I = varargin{length(varargin)};		% last argument always
   Index_right = get(Arguments, 'Value');
   Labels = get(Arguments, 'String');
   Temp_region_right = base2dec(Labels{Index_right}, 10);
   % restoring the old region first
   if Region_right{I}								% was defined
      if not(Region_left{I} == Region_right{I})
         Segment_demo('Draw boundary', Region_right{I}, I);
      end
   end
   Region_right{I} = Temp_region_right;
   Segment_demo('Draw boundary', Region_right{I}, 'white', I);
 

%-----------------------------------------   
elseif strcmp(Action, 'Cancel operation')		% don't perform operation
	I = varargin{length(varargin)};		% last argument always
   close;
   if Region_left{I}
      Segment_demo('Draw boundary', Region_left{I}, I);
      Region_left{I} = 0;
   end
   if Region_right{I}
      Segment_demo('Draw boundary', Region_right{I}, I);
      Region_right{I} = 0;   
   end
   Store_mouse_pts{I} = 0;
 

%-----------------------------------------
elseif strcmp(Action, 'Merge prompt')
	I = varargin{length(varargin)};		% last argument always
   Operation_prompt;								% the common piece
   Right_button;									% one more button here
	if Interactive
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Merge', 0, I);
		if Ok_button
			set(Ok_button, 'Callback', Callback);
		end
	else
		Callback=sprintf('Segment_demo(''%s'',%d,%d)', 'Merge', 1, I);
		eval(Callback);
	end
 
%-----------------------------------------   
elseif strcmp(Action, 'Merge')		% the two regions have been defined
	I = varargin{length(varargin)};		% last argument always
	if Arguments == 0							% interactive call
   	close;	% prompt
   end
   Bndred_regions{I} = Bndred_regions{I}+1;
   [Regions{I}{Bndred_regions{I}}.Public.Inner_pts, ...
   	Regions{I}{Bndred_regions{I}}.Public.Boundary, ...
		Regions{I}{Bndred_regions{I}}.Public.Shifts] = Merge_regions(...
			Regions{I}{Region_left{I}}.Public, Regions{I}{Region_right{I}}.Public);
   Regions{I}{Bndred_regions{I}}.Public.Region_matr = ...
		Region_matrix(Regions{I}{Bndred_regions{I}}.Public);
   Regions{I}{Bndred_regions{I}}.Private.Color = ...
      Region_colors{1, 1+rem(Bndred_regions{I}-1, size(Region_colors, 2))};
   Regions{I}{Bndred_regions{I}}.Private.Number = Bndred_regions{I};
	Regions{I}{Bndred_regions{I}}.Private.From=[Region_left{I}, Region_right{I}];
   Regions{I}{Bndred_regions{I}}.Public.Area = -99;
   Regions{I}{Bndred_regions{I}}.Public.Volume = -99;
   Regions{I}{Bndred_regions{I}}.Public.Avg_intensity = -99;
	Segment_demo('Draw boundary first time', Bndred_regions{I}, I);

  	Segment_demo('Enable region', Bndred_regions{I}, I);
   
	Segment_demo('Disable region', Region_left{I}, I);
	Segment_demo('Disable region', Region_right{I}, I);
   Region_left{I} = 0;	Region_right{I} = 0;


% --------------------
elseif strcmp(Action, 'Draw boundary first time')
	I = varargin{length(varargin)};		% last argument always
   Regions{I}{Arguments}.Private.Line = ...
      line('XData', Regions{I}{Arguments}.Public.Boundary(2, :), ...
      'YData', Regions{I}{Arguments}.Public.Boundary(1, :), ...
      'Parent', Main_axis{I}, 'Color', Regions{I}{Arguments}.Private.Color, ...
		'Marker', '.', 'LineStyle', '.', 'EraseMode', 'none', ...
		'Visible', 'off', 'LineWidth', Marker_size, 'MarkerSize', Marker_size);

% -------------------- since repeates so often
elseif strcmp(Action, 'Draw boundary')   
	I = varargin{length(varargin)};		% last argument always
   if length(varargin) == 1					% draw the region in the usual color
	  	if Regions{I}{Arguments}.Private.Active
      	set(Regions{I}{Arguments}.Private.Line, 'Visible', 'off');
      	set(Regions{I}{Arguments}.Private.Line, ...
         	'Color', Regions{I}{Arguments}.Private.Color, 'Visible', 'on');
	 	else
      	set(Regions{I}{Arguments}.Private.Line, 'Visible', 'off');
	 	end
   else
      if strcmp(varargin{1}, 'white')		% draw in white
         set(Regions{I}{Arguments}.Private.Line, ...
            'Color', 'white', 'Visible', 'on');
      elseif strcmp(varargin{1}, 'none')	% don't draw
         set(Regions{I}{Arguments}.Private.Line, 'Visible', 'off');
      end
   end
end

% let's represent regions (whose boundaries we were asked to find) by
% those boundaries and make the merging part as filling those
% boundaries and taking union as it was done before.  In this fashion
% we can handle new regions, not to abuse the original image.  Merging
% will be done on pairs of regions resulting in a new region
