function [none] = manual_detect(pid, time1, time2)
    %Add the location of the images
    addpath('..');
    addpath(genpath('../Test Set'));
    
    %Convert input to something else
    image_string = char(pid);
    
    %Check and create output path for the restuls
    output_path = 'manual_detect_output/';
    if(exist(output_path, 'dir') == 0)
        mkdir(output_path);
    end
    
    %Parse XML document and find this pictures information
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');
    
    path1 = '';
    path2 = '';
    
    %Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);
       
        %Get the attribute from the image tag
        id = char(image.getAttribute('id'));
        
        if strcmp(id, image_string) == 1  
            timeval = char(image.getAttribute('time'));
            if strcmp(timeval, time1) == 1
                path1 = char(image.getAttribute('path'));
            elseif strcmp(timeval, time2) == 1
                path2 = char(image.getAttribute('path'));
            end
        end
    end
    
    if ~isempty(path1) && ~isempty(path2)
        base = crop_footer(rgb2gray(imread(path1)));
        next = crop_footer(rgb2gray(imread(path2)));

        
        [img1, img2] = match_sizing(base, next);
        
        [xyinput_out, xybase_out] = cpselect(img2, img1, 'Wait', true);
        if size(xyinput_out, 1) >= 3 && size(xybase_out, 1) >= 3 && size(xyinput_out, 1) == size(xybase_out, 1)
        	[~, ~, ~, tform] = transform_it_vision(xybase_out, xyinput_out);
            [img1_correct, img2_correct] = apply_transform(tform, img1, img2);
            
            figure, imshowpair(img1_correct, img2_correct);
            
            button = questdlg('Would you like to save this registration pair?', ...
                              'Registerd images', 'Yes', 'No', 'No');
            if(strcmp(button, 'Yes') == 1)
                %Get the filenames
                count1 = parse_outname(path1);
                count2 = parse_outname(path2);

                %Build the output file name
                new_base_filename = [output_path, count1, '-', count2, '_baseimg.tif'];
                new_corr_filename = [output_path, count1, '-', count2, '_corrimg.tif'];

                %Write the corrected image pair to disk
                imwrite(img1_correct, new_base_filename, 'tif');
                imwrite(img2_correct, new_corr_filename, 'tif')
            end
        end
    end
end