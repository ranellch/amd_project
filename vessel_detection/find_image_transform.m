function [out] = find_image_transform(pid)
    %Add the location of the XML file with patient information
    addpath('..');
    
    %Add the location of the images
    addpath(genpath('../Test Set'));
    
    %Convert input to something else
    image_string = char(pid);

    %Parse XML document and find this pictures information
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');

    %Java lists to keep track of original filename and vessel detection
    the_list_orig = java.util.LinkedList;
    total_count = 0;
      
	%Loop on the image field in the images tag
    for count = 1:images.getLength
        image = images.item(count - 1);

        %Get the attribute from the image tag
        id = char(image.getAttribute('id'));
        path = char(image.getAttribute('path'));

        if strcmpi(id, image_string) == 1         
            %Keep track of original and new filename
            the_list_orig.add(path);
            total_count = total_count + 1;
        end
    end
        
	%Get the offest of the images
    for count1 = 0:total_count - 1
        %Get the base image
        base_img_real = char(the_list_orig.get(count1));
        
        %Loop on images to pair with
        for count2 = count1 + 1:total_count - 1
            %Get the next image to pair
            next_img_real = char(the_list_orig.get(count2));
            
            %Register the images and save in output directory (image_string)
            register_images(base_img_real, next_img_real, image_string);
        end
    end
end
