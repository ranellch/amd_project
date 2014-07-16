function register_set(pid, eye, time, mintime, maxtime, ref_eye)
    images_path = '../Test Set/';
    
    %Get paths to important functions
    addpath('..');
    addpath(genpath(images_path));
    addpath('../roi_mask');
    addpath('other_vessels');
    
    %Load the video xml and parse out the important information
    [video_xml_path, directory] = get_video_xml(pid, eye, time, 'seq_path');
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
        disp(e.stack);
        error(e.message);
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
        overlap_mask = ones(size(ref_image_roi, 1), size(ref_image_roi,2));

        docNode = com.mathworks.xml.XMLUtils.createDocument('video_seq');
        root = docNode.getDocumentElement;
        root.setAttribute('id',pid);
        root.setAttribute('timing',time);
        root.setAttribute('eye',eye);
        root.setAttribute('ref_eye',num2str(ref_eye));
        
        %Iterate over each image to register
        for i=1:count
            curtime = str2double(times{i});
            if curtime == ref_eye
                continue;
            end
            if curtime < mintime
                continue;
            end
            if curtime > maxtime
                break;
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
            
            %Save these images to the output array
            fused_img = imfuse(ref_image_roi, movingReg);

            %Save the original image to the output
            img_path = [pid, '_', times{i}, '.tif'];
            imwrite(movingReg,[dir_name, '/', img_path]);
            imwrite(fused_img, [dir_name, '/reg_', pid, '_', num2str(ref_eye), '-', times{i}, '.tif']);

            frameElement = docNode.createElement('frame');
            frameElement.setAttribute('id',num2str(i));
            frameElement.setAttribute('path',img_path);
            frameElement.setAttribute('time',times{i});
            root.appendChild(frameElement);
            
            if(i == 0)
                break;
            end
        end
                
        xmlwrite([dir_name, '/video.xml'], docNode);     
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

