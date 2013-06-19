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
    
    %Create the directory for the 
    vdetectdir = 'vdetect';
    if exist(vdetectdir, 'dir') == false
       mkdir(vdetectdir); 
    end
    
	%Loop on the image field in the images tag
	for count = 1:images.getLength
		image = images.item(count - 1);

        %Get the attribute from the image tag
        id = char(image.getAttribute('id'));
        path = char(image.getAttribute('path'));

        if strcmpi(id, image_string) == 1
            %Run the vessel detection algorithm on this image
            filename = vessel_detection(path, vdetectdir);
            disp(['Vessel Detect: ', path, ' -> ', filename]);
            
            %Keep track of original and new filename
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
            skip_quad = zeros(1,1);
            skip_quad(1, 1) = 5;
            quad_count = 3;
            tform = align_images_coor(base_img, next_img, quad_count, skip_quad);
            
            %Apply the tform transform to the original images
            [img1_correct, img2_correct] = apply_transform(tform, base_img_real, next_img_real);
            
            %Write the corrected image pair to disk
            imwrite(img1_correct, [image_string, '/', num2str(count1), '-', num2str(count2), '_baseimg.tif'], 'tif');
            imwrite(img2_correct, [image_string, '/', num2str(count1), '-', num2str(count2), '_corrimg.tif'], 'tif');
        end
    end
end
