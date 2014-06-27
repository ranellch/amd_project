function register_set(pid, eye, ref_eye)
    %Get paths to important functions
    addpath('..');
    addpath(genpath('../Test set'));
    addpath('../roi_mask');
    addpath('../Vessel Detection - Chris');
    run('../vlfeat/toolbox/vl_setup');
    
    %Get the count of the number of images in this set
    times = [];
    try
        cur_time = 1;
        found_ref = 0;
        while 1
            imgpath = get_pathv2(pid,eye,num2str(cur_time),'original');
            img = imread(imgpath);
            times = [times, cur_time];
            if cur_time == ref_eye
                found_ref = 1;
            end
            cur_time = cur_time + 1;
        end

        if(found_ref == 0)
            error(['Could not find reference eye with time: ', num2str(ref_eye)]);
        end
    catch e
        %error([e.message, ' - ', num2str(cur_time)]);
    end

    dir_name = ['results - ', pid];
    if(exist(dir_name, 'dir'))
        rmdir(dir_name, 's');
    end
    mkdir(dir_name);
    
    %Check to make sure that there are enough images that even need registering
    if (size(times,2) > 1 && ~isempty(find(times == ref_eye, 1)))
        cur_phase = num2str(times(1,ref_eye));
        
        disp(['[REF IMG ', cur_phase, '] Initializing reference image']);
        
        %Get the first image and load it into memory
        imgpath = get_pathv2(pid,eye,cur_phase,'original');
        ref_image = imread(imgpath);
        
        %Calculate the roi mask
        ref_image_mask = find_roi(pid,eye,cur_phase,'original',1);
        
        %Apply the roi mask to the original image
        ref_image_roi = apply_roi_mask(ref_image, ref_image_mask);
        
        %Calculate the vessel mask and resize to original size
        %ref_image_vessels = find_vessels(pid,eye,cur_phase,'complement',0);
        
        %Crop the vessel image to remove the black border
        crop_ref = find_square_inside_circle(ref_image_mask);
        ref_image_roi_crop = imcrop(ref_image_roi, crop_ref);
        
        %Create the results matricies
        registered_images = uint8(ones(size(times,2), 2, size(ref_image_roi, 1), size(ref_image_roi,2)));
        registered_images_fuse = uint8(ones(size(times,2), size(ref_image_roi, 1), size(ref_image_roi,2), 3));
        
        %Write the reference images to the results array
        registered_images(ref_eye,1,:,:) = ref_image_roi;
        registered_images(ref_eye,2,:,:) = ref_image_mask;
        
        %Iterate over each image to register
        for i=1:size(times,2)
            if i == ref_eye
                continue;
            end
                        
            %Get the image to register to the first image
            time = num2str(times(1, i));
            
            disp(['[IMAGE ', time, '] Registering']);
                        
            %Get the image path and then load into memory
            imgpath = get_pathv2(pid,eye,time,'original');
            img = imread(imgpath);
            
            %Calculate the roi mask
            img_mask = find_roi(pid,eye,time,'original',1);
            
            %Apply the roi mask to the original image
            img_roi = apply_roi_mask(img, img_mask);
            
            %Calculate the vessel mask
            %img_vessels = find_vessels(pid,eye,time,'complement',0);
                        
            %Crop the vessel image using the mask
            crop_roi = find_square_inside_circle(img_mask);
            img_roi_crop = imcrop(img_roi, crop_roi);
            
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

