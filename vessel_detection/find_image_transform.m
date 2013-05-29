function [out] = find_image_transform(pid)
	%Add the parent folder to the path
    addpath('..');
    addpath(genpath('../Test Set'));
    
    %Convert input to something else
	image_string = char(pid);

	%Parse XML document and find this pictures information
	xDoc= xmlread('images.xml');
	images = xDoc.getElementsByTagName('image');

    the_list = '';
    
	%Loop on the image field in the images tag
	for count = 1:images.getLength
		image = images.item(count - 1);

		%Get the attribute from the image tag
		id = char(image.getAttribute('id'));
		%time = char(image.getAttribute('time'));
		path = char(image.getAttribute('path'));

		if strcmpi(id, image_string) == 1
			optic_x = str2double(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent);
			optic_y = str2double(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent);
			macula_x = str2double(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent);
			macula_y = str2double(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent);

            filename = vessel_detection(path, optic_x, optic_y, macula_x, macula_y);
            disp(strcat('Run: ', path));
			the_list = strcat(the_list, filename, ',');
		end
    end
    
	%Get the offest of the images
    image_list = strsplit(the_list, ',');
	base_img = image_list(1);
	for count = 2:length(image_list)
        next_img = char(image_list(count));
		align_images_vl(base_img, next_img);
	end
end
