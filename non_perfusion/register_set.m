function register_set(pid, eye, time, ref_eye)
    images_path = '../Test Set/';
    
    %Get paths to important functions
    addpath('..');
    addpath(genpath(images_path));
    addpath('../roi_mask');
    addpath('other_vessels');
    
    %Load the video xml and parse out the important information
    [video_xml_path, directory] = get_video_xml(pid, eye, time, 'original_path');
    addpath([images_path, directory]);
    
    %Get all the frames associated with this video
    [count, paths, times] = get_images_from_video_xml(video_xml_path);
    
    %Get the count of the number of images in this set
    try
        found_ref = 0;
        for x=1:count
            cur_time = str2double(times{x});      
            if cur_time == ref_eye
                found_ref = 1;
                ref_image = imread(paths{x});
                ref_phase = times{x};
            end
        end

        if(found_ref == 0)
            error(['Could not find reference eye with time: ', num2str(ref_eye)]);
        end
    catch e
        error([e.message, ' - ', e.stack]);
    end
    
    dir_name = ['results - ', pid];
    if(exist(dir_name, 'dir'))
        rmdir(dir_name, 's');
    end
    mkdir(dir_name);
    
    %Check to make sure that there are enough images that even need registering
    if (count > 2)        
        disp(['[REF IMG ', ref_phase, '] Initializing reference image']);
                
        %Calculate the roi mask
        ref_image_mask = find_roi(ref_image, 1);
        
        %Apply the roi mask to the original image
        ref_image_roi = apply_roi_mask(ref_image, ref_image_mask);
        
        %Calculate the vessel mask and resize to original size
        ref_image_vessels = find_vessels(ref_image_roi);
        
        %Crop the vessel image to remove the black border
        crop_ref = find_square_inside_circle(ref_image_mask);
        ref_image_roi_crop = imcrop(ref_image_vessels, crop_ref);
                
        %Create the results matricies
        registered_images = uint8(ones(size(times,2), 2, size(ref_image_roi, 1), size(ref_image_roi,2)));
        registered_images_fuse = uint8(ones(size(times,2), size(ref_image_roi, 1), size(ref_image_roi,2), 3));
        
        %Write the reference images to the results array
        registered_images(ref_eye,1,:,:) = ref_image_roi;
        registered_images(ref_eye,2,:,:) = ref_image_mask;
        
        %Iterate over each image to register
        for i=1:count
            curtime = str2double(times{i});
            if curtime == ref_eye
                continue;
            end
                                    
            disp(['[IMAGE ', times{i}, '] Registering']);
                        
            %Get the image path and then load into memory
            imgpath = paths{i};
            img = imread(imgpath);
            
            %Calculate the roi mask
            img_mask = find_roi(img);
            
            %Apply the roi mask to the original image
            img_roi = apply_roi_mask(img, img_mask);
            
            %Calculate the vessel mask
            img_vessels = find_vessels(img_roi);
            
            %Crop the vessel image using the mask
            crop_roi = find_square_inside_circle(img_mask);
            img_roi_crop = imcrop(img_vessels, crop_roi);
                        
            %Calculate image transform from the cropped images
            tform = imregcorr(img_roi_crop, ref_image_roi_crop);
            Rfixed = imref2d(size(ref_image_roi));
            
            %Transform the original image and mask
            movingReg = imwarp(img_roi, tform, 'OutputView', Rfixed);
            movingRegMask = imwarp(img_mask, tform, 'OutputView', Rfixed);
            
            %Save these images to the output array
            registered_images(i,1,:,:) = movingReg;
            registered_images(i,2,:,:) = movingRegMask;
            registered_images_fuse(i,:,:,:) = imfuse(ref_image_roi, movingReg);

            if(i == 0)
                break;
            end
        end
        
        %Calculate the final output mask of overlap
        output_mask = ones(size(ref_image_mask, 1), size(ref_image_mask, 2));
        for i=1:size(registered_images,1)
            %Get the current time as a string
            cur_time_string = num2str(i);
                       
            %Add the masked region to the final mask
            output_mask = output_mask & squeeze(registered_images(i,2,:,:));
            
            %Save the original image to the output
            imwrite(squeeze(registered_images(i,1,:,:)),[dir_name, '/', pid, '_', cur_time_string, '.tif']);
                        
            %Save the overlayed image to the output
            if(strcmp(cur_time_string, num2str(ref_eye)) == 0)
                fused_img = squeeze(registered_images_fuse(i,:,:,:));
                imwrite(fused_img, [dir_name, '/reg_', pid, '_', num2str(ref_eye), '-', cur_time_string, '.tif']);
            end
        end
        
        imwrite(output_mask, [dir_name, '/', pid, '_final_mask.tif']);        
    end
end

function [results] = apply_roi_mask(img, mask)
    results = img;
    for y=1:size(img,1)
        for x=1:size(img,2)
            if(mask(y,x) ~= 1)
                results(y,x) = 0;
            end
        end
    end
end

function [points] = find_square_inside_circle(mask)
    centroids = regionprops(mask, 'Centroid');
    diameter = regionprops(mask, 'MinorAxisLength');
    if(size(centroids.Centroid, 1) ~= 1)
        points = [0, 0, size(mask,1), size(mask,2)];
    else
        cx = centroids.Centroid(1,1);
        cy = centroids.Centroid(1,2);
        
        side_length = diameter.MinorAxisLength * (sqrt(2) / 2);
        center_off = side_length / 2.0;
        x1 = cx - center_off;
        %x2 = cx + center_off;
        y1 = cy - center_off;
        %y2 = cy + center_off;
        points = [x1, y1, side_length, side_length];
    end
end

