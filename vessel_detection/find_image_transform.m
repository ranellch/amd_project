function [out] = find_image_transform(pid)
	%Add the parent folder to the path
    addpath('..');
    addpath(genpath('../Test Set'));
    
    %Convert input to something else
	image_string = char(pid);

	%Parse XML document and find this pictures information
	xDoc= xmlread('images.xml');
	images = xDoc.getElementsByTagName('image');

    %Java lists to keep track of original filename and vessel detection
    the_list_orig = java.util.LinkedList;
    the_list = java.util.LinkedList;
    total_count = 0;
    
	%Loop on the image field in the images tag
	for count = 1:images.getLength
		image = images.item(count - 1);

		%Get the attribute from the image tag
		id = char(image.getAttribute('id'));
		path = char(image.getAttribute('path'));

		if strcmpi(id, image_string) == 1
            filename = vessel_detection(path);
            disp(['Vessel Detect: ', path, ' -> ', filename]);
            the_list_orig.add(path);
            the_list.add(filename);
            total_count = total_count + 1;
		end
    end
    
    %Create the output directory for this badboy
    if total_count > 1 && exist(image_string, 'dir') == false
       mkdir(image_string); 
    end
    
	%Get the offest of the images
	for count1 = 0:total_count - 1
        %Get the base image
        base_img = char(the_list.get(count1));
        base_img_real = char(the_list_orig.get(count1));
        %Loop on images to pair with
        for count2 = count1 + 1:total_count - 1
            %Get the next image to pair
            next_img = char(the_list.get(count2));
            next_img_real = char(the_list_orig.get(count2));
            
            %Find the tform matrix to alter next_img to be like base_img
            tform = align_images_coor(base_img, next_img);
            
            %Apply the tform transform
            [img1_correct, img2_correct] = apply_transform(tform, base_img_real, next_img_real);
            
            %Write the output images to disk
            imwrite(img1_correct, [image_string, '/', num2str(count1), '-', num2str(count2), '_baseimg.tif'], 'tif');
            imwrite(img2_correct, [image_string, '/', num2str(count1), '-', num2str(count2), '_corrimg.tif'], 'tif');
        end
    end
end
