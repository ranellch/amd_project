function [out] = find_transform()
	img = '00036771';
	
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
		if strcmpi(id, img)
			optic_x = char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent);
			optic_y = char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent);
			macula_x = char(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent);
			macula_y = char(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent);
			images_to_compare(time) = [path, ',', optic_x,',', optic_y,',', macula_x,',', macula_y];
		end
	end

	%Run the transform on the images
	for count = 1:length(images_to_compare)
		key = int2str(count - 1);
		info_array = images_to_compare(key);
		disp(strcat('Image(', int2str(count), '):  ', info_array));
		
		splitit = regexp(info_array, '[,]', 'split');
		file = char(splitit(1));
		optic_x = str2num(char(splitit(2)));
		optic_y = str2num(char(splitit(3)));
		macula_x = str2num(char(splitit(4)));
		macula_y = str2num(char(splitit(5)));
		filename = vessel_detection(file, optic_x, optic_y, macula_x, macula_y);

		images_to_compare(key) = filename;
	end

	%Get the offest of the images
	base_img = images_to_compare('0');
	for count = 2:length(images_to_compare)
		next_img = char(images_to_compare(key));

		
	end
end
