function register_manual(pid, eye, ref, time)
    addpath('..');
    addpath(genpath('../Test Set'));
    addpath('../roi_mask');
    dir_name = ['results - ', pid];

    ref_string = num2str(ref);
    ref_path = get_pathv2(pid, eye, ref_string, 'original');
    ref_image = imread(ref_path);
    ref_image_mask = find_roi(pid, eye, ref_string, 'original',1);
    ref_image_roi = apply_roi_mask(ref_image, ref_image_mask);
    
    time_string = num2str(time);
    time_path = get_pathv2(pid, eye, time_string, 'original');
    time_image = imread(time_path);
    time_image_mask = find_roi(pid, eye, time_string, 'original', 1);
    time_image_roi = apply_roi_mask(time_image, time_image_mask);
    
    [aerial_points, ortho_points] = cpselect(time_image_roi, ref_image_roi, 'Wait', true);
    %t_concord = fitgeotrans(aerial_points,ortho_points,'projective');
    %Rortho = imref2d(size(time_image_roi));
    %registered = imwarp(time_image_roi,t_concord,'OutputView',Rortho);
    tform = cp2tform(aerial_points, ortho_points, 'projective');
    registered = imtransform(time_image_roi, tform);
    
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