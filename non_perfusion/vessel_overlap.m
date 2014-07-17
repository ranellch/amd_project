function vessel_overlap(pid, eye, time, mintime, maxtime, varargin)
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
            
    vessel_mask = zeros(1);
    for k=1:count
        try
            %Get the current time and check if above maxtime
            cur_time = str2double(times{k});
            if(cur_time < mintime)
                continue;
            end
            if(cur_time > maxtime)
                break; 
            end
    
            %Get the current path and load the image
            cur_path = path{k};
            img = imread(cur_path);
                                  
            %If this is the first image in the set then initialized the output variable
            if(k == 1)
                vessel_mask = zeros(size(img,1), size(img,2));
            end

            starttime = cputime;

            %Run vessel detection algorithm upon the image
            vessel_img = find_vessels(img, debug);
            
            endtime = cputime;
            
            if debug > 1
                disp(['[VESSELS] Time: ', times{k},' - Run Classifier Time (sec): ', num2str(endtime - starttime)]);
            end
            
            %Logical OR the vessel detection image with the other vessel maps
            vessel_mask = vessel_mask | vessel_img;
            
            if(debug == 2)
                figure(1), imshow(vessel_mask);
            end
        catch e
            disp(e.stack);
            error(e.message);
        end
    end
    
    outputpath = [images_path, directory, '/', pid, '_', eye, '_', time,'_vessel-overlap.tif'];
    disp(['SAVED TO: ', outputpath]);
    imwrite(vessel_mask, outputpath);
    update_video_xml(pid, eye, time, 'vessel_path', outputpath);
end