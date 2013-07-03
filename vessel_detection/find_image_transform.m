function [out] = find_image_transform(pid)
    %Add the location of the XML file with patient information
    addpath('..');
    
    %Add the location of the images
    addpath(genpath('../Test Set'));
    
    %Convert input to something else
    image_string = char(pid);
    output_path = ['results/', image_string];

    %Parse XML document and find this pictures information
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');

    %Java lists to keep track of original filename and vessel detection
    the_list_orig = java.util.LinkedList;
    the_list_transform = java.util.LinkedList;
    total_count = 0;
      
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        %Get the attribute from the image tag
        id = char(image.getAttribute('id'));

        if strcmp(id, image_string) == 1       
            path = char(image.getAttribute('path'));
            transform = 'none';
            
            %If invert tag exists then get it else invert is alse by default
            try
                transform = char(image.getAttribute('transform'));
            catch 
                transform = 'none';
            end
        
            the_list_transform.add(transform);
        
            %Keep track of original and new filename
            the_list_orig.add(path);
            total_count = total_count + 1;
        end
    end
    
    disp(['To Run ', num2str(total_count), ' images from: ', image_string]);
    
	%Get the offest of the images
    for count1 = 0:total_count - 1
        %Get the base image
        base_img_real = char(the_list_orig.get(count1));
        basetrans = char(the_list_transform.get(count1));
        
        %Loop on images to pair with
        for count2 = count1 + 1:total_count - 1
            %Get the next image to pair
            next_img_real = char(the_list_orig.get(count2));
            nextrans = char(the_list_transform.get(count2));
            
            %Register the images and save in output directory (image_string)
            register_images(base_img_real, basetrans, next_img_real, nextrans, output_path);
        end
    end
end
