function time_lapse(pid, eye, time, maxtime, varargin)
    %This functions puts the images into a movie that just looks at intensity though time.
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
    
    %Load the video xml and parse out the important information
    [video_xml_path, directory] = get_video_xml(pid, eye, time, 'seq_path');
    addpath([images_path, directory]);
    
    %Get all the frames associated with this video
    [count, path, times] = get_images_from_video_xml(video_xml_path);
    
    %Fetch the precomputed ROI mask
    disp('----------Fetching ROI---------');
    [roi_path, roi_directory] = get_video_xml(pid, eye, time, 'roi_path');
    addpath([images_path, roi_directory]);
    roi_mask = imread(roi_path);
    if(debug == 2)
        figure, imshow(roi_mask);
    end
    disp('-------Done Fetching ROI-------');

    %Fetch the precomputed vessels mask
    disp('----------Fetching Vessels---------');
    [vessel_path, vessel_directory] = get_video_xml(pid, eye, time, 'vessel_path');
    addpath([images_path, vessel_directory]);
    vessel_mask = imread(vessel_path);
    vessel_mask = bwmorph(vessel_mask,'thicken',3);
    if(debug == 2)
        figure, imshow(vessel_mask);
    end
    disp('----------Done Fetching Vessels---------');
    
    %Output results
    final_graph = uint8(zeros(size(roi_mask,1), size(roi_mask,2), count));
    
    if(debug == 2)
        %Video writer for time lapse of intensity
        uncompressedVideo = VideoWriter(['time_lapse_videos/',pid, '_', eye, '.avi'], 'Uncompressed AVI');
        uncompressedVideo.FrameRate = 3;
        open(uncompressedVideo);
    end
    
    %Iterate over the files
    for k=1:count
        try
            %Get the current time and check if above maxtime
            cur_time = str2double(times{k});
            if(cur_time > maxtime)
                break; 
            end
            
            %Get the current path and load the image
            cur_path = path{k};
            img = imread(cur_path);
            if(size(img,3) > 1)
                img = rgb2gray(img);
            end
            
            %Get the intensities over time
            for y=1:size(img,1)
                for x=1:size(img,2)
                    if(roi_mask(y,x) == 1 && vessel_mask(y,x) == 0)
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
