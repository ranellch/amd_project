function [out] = find_image_transform(pid)
   
    resize = true;
    
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

    %Start map object
    mapObj = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
    
    %Java lists to keep track of original filename and vessel detection
    the_list_path = java.util.LinkedList;
    the_list_transform = java.util.LinkedList;
    total_count = 0;
      
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        %Get the attribute from the image tag
        id = char(image.getAttribute('id'));
        
        if strcmp(id, image_string) == 1       
            the_path = char(image.getAttribute('path'));
            the_time = char(image.getAttribute('time'));
            transform = 'none';
            
            %Get a map list of the images to compare
            mapObj(str2num(the_time)) = total_count;
            
            %If transform tag exists then get it else keep as null
            try
                transform = char(image.getAttribute('transform'));
            catch 
                transform = 'none';
            end
            the_list_transform.add(transform);
                    
            %Get the path name for this badboy
            the_list_path.add(the_path);
            
            %Increment the index of the 
            total_count = total_count + 1;
        end
    end
    
    %Get the time keys in order so that images are only run once going forward
    the_keys = keys(mapObj);
    
    %Calculate the number of paris that are going to be run
    total_pairs = ((length(the_keys) * (length(the_keys) - 1)) / 2);
    
    %Write to console for user's benefit
    disp(['To Run ', num2str(total_count), ' images for a total of ', num2str(total_pairs),' pairs from: ', image_string]);
    
	%Get the offest of the images
    for count1=1:length(the_keys)
        index1 = mapObj(the_keys{count1});
        
        %Get the base image
        base_img_real = char(the_list_path.get(index1));
        basetrans = char(the_list_transform.get(index1));
        
        %Loop on images to pair with
        for count2=count1+1:length(the_keys)
            index2 = mapObj(the_keys{count2});
            
            %Get the next image to pair
            next_img_real = char(the_list_path.get(index2));
            nextrans = char(the_list_transform.get(index2));
            
            %Register the images and save in output directory (image_string)
        %    register_images(base_img_real, basetrans, next_img_real, nextrans, output_path, resize);
        %    register_images_ML(base_img_real, basetrans, next_img_real, nextrans, output_path, resize);
            register_images_MLdataset(base_img_real, next_img_real, pid, output_path, resize);
            return;
        end
    end
end
