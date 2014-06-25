function register_set(pid, eye)
    addpath('..');
    addpath(genpath('../Test set'));
    addpath('../roi_mask');
    run('../vlfeat/toolbox/vl_setup');
    
    %Get the count of the number of images in this set
    times = [];
    cur_time = 1;
    try
        while 1
            imgpath = get_pathv2(pid,eye,num2str(cur_time),'original');
            times = [times, cur_time];
            cur_time = cur_time + 1;
        end
    catch e
        %disp(e.message);
    end
    
    if (size(times,2) > 1)
        %Get the first image
        imgpath = get_pathv2(pid,eye,num2str(times(1,1)),'original');
        first_image = imread(imgpath);
        first_image_mask = find_roi(pid,eye,num2str(times(1,1)));
        first_image_roi = apply_roi_mask(first_image, first_image_mask);
        
        for i=2:size(times,2)
            %Get the image to register to the first image
            time = num2str(times(1, i));
            imgpath = get_pathv2(pid,eye,time,'original');
            img = imread(imgpath);
            img_mask = find_roi(pid,eye,time);
            img_roi = apply_roi_mask(img, img_mask);
            
            
        end
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