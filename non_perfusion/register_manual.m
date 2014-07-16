function register_manual(pid, eye, timing, ref, time)
    addpath('..');
    images_path = '../Test Set/';
    addpath(genpath(images_path));
    addpath('../roi_mask');
    dir_name = ['results - ', pid];

    ref_string = num2str(ref);
    time_string = num2str(time);
            
    %Load the video xml and parse out the important information
    [video_xml_path, directory] = get_video_xml(pid, eye, timing, 'original_path');
    addpath([images_path, directory]);
    
    %Get all the frames associated with this video
    [count, paths, times] = get_images_from_video_xml(video_xml_path);
    
    for i=1:count
        if(str2double(times{i}) == ref)
            ref_path = paths{i};
        end
        if(str2double(times{i}) == time)
            time_path = paths{i};
        end
    end
    
    ref_image = imread(ref_path);
    ref_image_mask = find_roi(ref_image,1);
    ref_image_roi = apply_roi_mask(ref_image, ref_image_mask);
    
    time_image = imread(time_path);
    time_image_mask = find_roi(time_image, 1);
    time_image_roi = apply_roi_mask(time_image, time_image_mask);
    
    [aerial_points, ortho_points] = cpselect(time_image_roi, ref_image_roi, 'Wait', true);
    t_concord = fitgeotrans(aerial_points,ortho_points,'Affine');
    Rortho = imref2d(size(time_image_roi));
    registered = imwarp(time_image_roi,t_concord,'OutputView',Rortho);
    %tform = cp2tform(aerial_points, ortho_points, 'projective');
    %registered = imtransform(time_image_roi, tform);
    
    fused = imfuse(registered,ref_image_roi);
    figure(1), imshow(fused);
    button = questdlg('Does this registration look good?','Good Reg?', 'Yes', 'No', 'Yes');
    
    switch button
        case 'Yes'
            imwrite(registered, [dir_name, '/', pid, '_', time_string, '.tif']);
            imwrite(fused, [dir_name, '/reg_', pid, '_', ref_string, '-', time_string, '.tif']);
        case 'No'
            
    end
end

function [results] = apply_roi_mask(img, mask)
    results = img;
    for y=1:size(mask,1)
        for x=1:size(mask,2)
            if mask(y,x) == 0
                results(y,x) = 0;
            end
        end
    end
end