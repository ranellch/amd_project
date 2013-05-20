function [out] = find_image_transform(pid)
	%Convert input to something else
    image_string = char(pid);

    %Parse XML document and find this pictures information
	xDoc= xmlread('images.xml');
	images = xDoc.getElementsByTagName('image');

	images_to_compare = containers.Map('KeyType','char','ValueType','any');

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
            
			images_to_compare(time) = [path, ',', optic_x,',', optic_y,',', macula_x,',', macula_y, ',', values];
		end
	end

	%Run the transform on the images in order
	for count = 1:length(images_to_compare)
		key = int2str(count - 1);
		info_array = images_to_compare(key);
		disp(strcat('Image(', int2str(count), '):  ', info_array));
		
		splitit = regexp(info_array, '[,]', 'split');
		file = char(splitit(1));
		optic_x = str2double(char(splitit(2)));
		optic_y = str2double(char(splitit(3)));
		macula_x = str2double(char(splitit(4)));
		macula_y = str2double(char(splitit(5)));
		type = char(splitit(6));
		x1 = str2double(char(splitit(7)));
		y1 = str2double(char(splitit(8)));
		x2 = str2double(char(splitit(9)));
		y2 = str2double(char(splitit(10)));

		filename = vessel_detection(file, optic_x, optic_y, macula_x, macula_y, type, x1, y1, x2, y2);
		
		images_to_compare(key) = filename;
	end

	%Get the offest of the images
	base_img = images_to_compare('0');
	for count = 2:length(images_to_compare)
		next_img = char(images_to_compare(key));
		align_images_vl(base_img, next_img);
	end
end
