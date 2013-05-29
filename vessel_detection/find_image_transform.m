function [scale, x, y, theta] = find_image_transform(pid, base, next)
	%Convert input to something else
    image_string = char(pid);

    %Parse XML document and find this pictures information
	xDoc= xmlread('images.xml');
	images = xDoc.getElementsByTagName('image');

    base_val = '';
    next_val = '';
    
	%Loop on the image field in the images tag
	for count = 1:images.getLength
		image = images.item(count - 1);

		%Get the attribute from the image tag
		id = char(image.getAttribute('id'));
		time = char(image.getAttribute('time')); 
		path = char(image.getAttribute('path'));

		if strcmpi(id, image_string) == 1
			optic_x = char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent);
			optic_y = char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent);
			macula_x = char(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent);
			macula_y = char(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent);
			type = char(image.getElementsByTagName('region').item(0).getAttribute('type'));
			
            values = '';
            if(strcmpi(type, 'square') == 1)
				x1 = char(image.getElementsByTagName('region').item(0).getElementsByTagName('top_left').item(0).getElementsByTagName('x').item(0).getTextContent);
				y1 = char(image.getElementsByTagName('region').item(0).getElementsByTagName('top_left').item(0).getElementsByTagName('y').item(0).getTextContent);
				x2 = char(image.getElementsByTagName('region').item(0).getElementsByTagName('bottom_right').item(0).getElementsByTagName('x').item(0).getTextContent);
				y2 = char(image.getElementsByTagName('region').item(0).getElementsByTagName('bottom_right').item(0).getElementsByTagName('y').item(0).getTextContent);
				values = strcat('square,',x1,',',y1,',',x2,',',y2);
            end
            
            if strcmpi(time, base) == 1
                base_val = [path, ',', optic_x,',', optic_y,',', macula_x,',', macula_y, ',', values];
            elseif strcmpi(time, next) == 1
                next_val = [path, ',', optic_x,',', optic_y,',', macula_x,',', macula_y, ',', values];
            end
		end
    end
    
    
	%Parse all of the information out of the string
	splitit = regexp(base_val, '[,]', 'split');
    base_file = char(splitit(1));
	base_optic_x = str2double(char(splitit(2)));
	base_optic_y = str2double(char(splitit(3)));
	base_macula_x = str2double(char(splitit(4)));
	base_macula_y = str2double(char(splitit(5)));
    base_type = char(splitit(6));
    base_x1 = str2double(char(splitit(7)));
    base_y1 = str2double(char(splitit(8)));
    base_x2 = str2double(char(splitit(9)));
    base_y2 = str2double(char(splitit(10)));

    %Crop the image
    base = imread(base_file);
	if strcmpi(base_type, 'square') == 1
		diffx = base_x2 - base_x1;
		diffy = base_y2 - base_y1;
		base = imcrop(base, [base_x1, base_y1, diffx, diffy]);
        %base = vessel_detection(base, base_optic_x, base_optic_y, base_macula_x, base_macula_y)
    end

    splitit = regexp(next_val, '[,]', 'split');
    next_file = char(splitit(1));
	next_optic_x = str2double(char(splitit(2)));
	next_optic_y = str2double(char(splitit(3)));
	next_macula_x = str2double(char(splitit(4)));
	next_macula_y = str2double(char(splitit(5)));
    next_type = char(splitit(6));
    next_x1 = str2double(char(splitit(7)));
    next_y1 = str2double(char(splitit(8)));
    next_x2 = str2double(char(splitit(9)));
    next_y2 = str2double(char(splitit(10)));
    
	%Crop the image
	next = imread(next_file);
	if strcmpi(next_type, 'square') == 1
		diffx = next_x2 - next_x1;
		diffy = next_y2 - next_y1;
		next = imcrop(next, [next_x1, next_y1, diffx, diffy]);
        %next = vessel_detection(next, next_optic_x, next_optic_y, next_macula_x, next_macula_y);
    end

    
	align_images(base, next);
end
