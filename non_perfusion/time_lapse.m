function time_lapse(pid, eye, maxtime, varargin)
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
    addpath(genpath('../Test Set'));
    addpath('../roi_mask');
    addpath('np_vessel');
    
    %Load the video xml and parse out the important information
    video_xml_path = get_video_xml(pid, eye, '0');
    [count, path, times] = get_images_from_video_xml(video_xml_path);
        
    %Test to make sure that all the appropiate images are available
    disp('----------Building ROI---------');
    roi_mask = zeros(1);
    try
        for x=1:count
            %Get the current timing stamp
            cur_time = str2double(times(x));
            if(cur_time > maxtime)
                break; 
            end
            
            %Check to see that the path to the image is readable
            cur_path = path(x);
            img = imread(cur_path);

            %If this is the first image in the set then initialized the output variable
            if(cur_time == 1)
                roi_mask = ones(size(img,1), size(img,2));
            end
            
            %Get the roi mask for the current image
            cur_mask  = find_roi(img, 1);
                        
            %And the roi mask for the current image with the running roi mask
            roi_mask = roi_mask & cur_mask;
        end
    catch e
        disp(e.message);
    end
    disp('-------Done Buildilng ROI-------');
        
    if(debug == 2)
        figure, imshow(roi_mask);
    end

    disp('----------Building Vessels---------');
    vessel_mask = zeros(size(roi_mask,1), size(roi_mask,2));
    for k=1:count
        try
            %Get the current time and check if above maxtime
            cur_time = times(k,1);
            if(cur_time > maxtime)
                break; 
            end
            
            %Get the current path and load the image
            cur_path = path(k,1);
            img = imread(cur_path);
            
            %Run vessel detection algorithm upon the image
            vessel_img = find_vessels(img, debug);
            
            %Logical OR the vessel detection image with the other vessel maps
            vessel_mask = vessel_mask | vessel_img;
        catch e
            error(e.message);
        end
    end
    disp('----------Done Building Vessels---------');
    
    if(debug == 2)
        figure(2), imshow(vessel_mask);
    end
    
    %Output results
    final_graph = uint8(zeros(size(roi_mask,1), size(roi_mask,2), size(image_times,2)));
    
    if(debug == 2)
        %Video writer for time lapse of intensity
        uncompressedVideo = VideoWriter([pid, '_', eye, '.avi'], 'Uncompressed AVI');
        uncompressedVideo.FrameRate = 1;
        open(uncompressedVideo);
    end
    
    %Iterate over the files
    for k=1:count
        try
            %Get the current time and check if above maxtime
            cur_time = times(k,1);
            if(cur_time > maxtime)
                break; 
            end
            
            %Get the current path and load the image
            cur_path = path(k,1);
            img = imread(cur_path);
            if(size(img,3) > 1)
                img = rgb2gray(img);
            end
            img = im2double(img);
                        
            %Get the intensities over time
            for y=1:size(img,1)
                for x=1:size(img,2)
                    if(roi_mask(y,x) == 1 && vessel_img(y,x) == 0)
                        final_graph(y,x,k) = img(y,x);
                    end
                end
            end
            
            if(debug == 2)                
                %Color the image into a heatmap
                heatmap = ind2rgb(squeeze(final_graph(:,:,k)), jet(256));
                                
                %Write the heatmap to an output video stream
                writeVideo(uncompressedVideo, heatmap);
            end
        catch e
            error(e.message);
        end
    end
        
    if(debug == 2)
        %Close the output video
        close(uncompressedVideo);
    end
end
