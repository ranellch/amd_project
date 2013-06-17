function [out] = find_image_transform(pid)
	%Add the parent folder to the path
    addpath('..');
    addpath(genpath('../Test Set'));
    
    %Convert input to something else
	image_string = char(pid);

	%Parse XML document and find this pictures information
	xDoc= xmlread('images.xml');
	images = xDoc.getElementsByTagName('image');

    the_list = java.util.LinkedList;
    total_count = 0;
    
	%Loop on the image field in the images tag
	for count = 1:images.getLength
		image = images.item(count - 1);

		%Get the attribute from the image tag
		id = char(image.getAttribute('id'));
		%time = char(image.getAttribute('time'));
		path = char(image.getAttribute('path'));

		if strcmpi(id, image_string) == 1
			%optic_x = str2double(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent);
			%optic_y = str2double(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent);
			%macula_x = str2double(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent);
			%macula_y = str2double(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent);

            filename = vessel_detection(path);%, optic_x, optic_y, macula_x, macula_y);
            disp(['Run:', path, ' -> ', filename]);
            the_list.add(filename);
            total_count = total_count + 1;
		end
    end
        
	%Get the offest of the images
	for count1 = 0:total_count - 1
        base_img = char(the_list.get(count1));
        for count2 = count1 + 1:total_count - 1
            next_img = char(the_list.get(count2));
            offset = align_images_coor(base_img, next_img);
            disp(['Compare: ', base_img, ' = ', next_img]);
        end
    end
end
