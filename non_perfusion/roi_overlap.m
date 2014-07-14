function [roi_mask] = roi_overlap(pid, eye, time, mintime, maxtime, varargin)
    images_path = '../Test Set/';
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arguments'));
    end
   
    %Add the location of the external scripts that we are going to call
    addpath('..');
    addpath(genpath(images_path));
    addpath('../roi_mask');
    
    %Load the video xml and parse out the important information
    [video_xml_path, directory] = get_video_xml(pid, eye, time, 'seq_path');
    addpath([images_path, directory]);
    
    %Get all the frames associated with this video
    [count, path, times] = get_images_from_video_xml(video_xml_path);
    
        %Test to make sure that all the appropiate images are available
    disp('----------Building ROI---------');
    roi_mask = ones(1);
    try
        for x=1:count
            %Get the current timing stamp
            cur_time = str2double(times{x});
            if(cur_time < mintime)
                continue;
            end
            if(cur_time > maxtime)
                break;
            end
            
            %Check to see that the path to the image is readable
            cur_path = path{x};
            img = imread(cur_path);

            %If this is the first image in the set then initialized the output variable
            if(x == 1)
                roi_mask = ones(size(img,1), size(img,2));
            end
            
            %Get the roi mask for the current image
            cur_mask  = find_roi(img, 1);
                        
            %And the roi mask for the current image with the running roi mask
            roi_mask = roi_mask & cur_mask;
            
            if(debug == 2)
                figure(1), imshow(roi_mask);
            end
        end
    catch e
        disp(e.message);
    end
    disp('-------Done Buildilng ROI-------');
            
    outputpath = [images_path, directory, '/', pid, '_', eye, '_', time,'_roi-overlap.tif'];
    disp(['SAVED TO: ', outputpath]);
    imwrite(roi_mask, outputpath);
end