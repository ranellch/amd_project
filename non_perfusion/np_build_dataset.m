function np_build_dataset(varargin)
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
        valid_debug(debug);
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
    end
    
    %constant for standard image sizes
    std_img_size = 768;

    disp('Building the non_perfusion dataset');
    
    %Path constants
    images_path = '../Test Set/';
    addpath('illum');
    addpath('xmlfunc');
    addpath('auxfunc');
    
    %Remove file is already exists
    filename_data = 'np_data.mat';
    if exist(filename_data, 'file') == 2
        delete(filename_data);
    end
    
    t = cputime;
    
    try
        %Open the file to determine which images to use for training 
        fid = fopen('np.training', 'r');
        paths = textscan(fid,'%q %q %q %*[^\n]');
        fclose(fid);
        
        numimages = size(paths{1}, 1);
        
        %Make sure that all images and paths exist
        addpath(genpath(images_path));
        disp('----Checking Files----');
        for k=1:numimages
            pid = char(paths{1}{k});
            eye = char(paths{2}{k});
            time = char(paths{3}(k));
            
            [video_xml, directory] = get_video_xml(pid, eye, time, 'seq_path');
            
            disp([pid, ' - ', eye, ' - ', time]);
        end
        disp('-----Done Checking Files-----');
        
        %Open and create the file to hold the video sets written to mat files
        names_matrix = [];
        
        %Iterate over all images to use for training 
        for i=1:numimages            
            pid = char(paths{1}{i});
            eye = char(paths{2}{i});
            time = char(paths{3}(i));
                        
            %Get the current video to analyze
            [video_xml, directory] = get_video_xml(pid, eye, time, 'seq_path');
            addpath([images_path, directory]);
            [counter, frame_paths, frame_times] = get_images_from_video_xml(video_xml);
            
            %Display to the user the current video going to be analyzed
            disp(['[PID] ', pid, ' [Eye] ', eye, ' [Time] ', time, ' [# FRAMES] ', num2str(counter)]);
            
            %Create the output matfile name base
            filename_output = [pid, '_', eye, '_', time];
            
            %Create the data out file
            data_out = pad_out_string([filename_output, '.mat']);
            if exist(strtrim(data_out), 'file') == 2
                delete(strtrim(data_out));
            end
            
            %Create the time out file
            time_out = pad_out_string([filename_output, '_time.mat']);
            if exist(strtrim(time_out), 'file') == 2
                delete(strtrim(time_out));
            end
            
            %Create the labeled matrix out
            labeled_out = pad_out_string([filename_output, '_labeled.mat']);
            if exist(strtrim(labeled_out), 'file') == 2
                delete(strtrim(labeled_out));
            end
            
            %Save the filename to the output file
            temp = cellstr([data_out; time_out; labeled_out]);
            names_matrix = [names_matrix temp];
            
            %Get the roi mask
            [roi_path, roi_directory] = get_video_xml(pid, eye, time, 'roi_path');
            addpath([images_path, roi_directory]);
            roi_mask = imread(roi_path);
            roi_mask = imresize(roi_mask, [std_img_size, NaN]);
            
            %Get the vessel mask
            [vessel_path, vessel_directory] = get_video_xml(pid, eye, time, 'vessel_path');
            addpath([images_path, vessel_directory]);
            vessel_mask = imread(vessel_path);
            vessel_mask = imresize(vessel_mask, [std_img_size, NaN]);
            
            %Overlap the roi and vessel mask
            positive_image = roi_mask & ~vessel_mask;
            
            %Get the labeled image and process it into a mask
            [labeled_path, labeled_directory] = get_video_xml(pid, eye, time, 'labeled_path');
            addpath([images_path, labeled_directory]);
            labeled_mask = imread(labeled_path);
            labeled_mask = imresize(labeled_mask, [std_img_size, NaN]);
            labeled_mask = process_labeled(labeled_mask);

            %Create all the matricies for holding the results
            data_matrix = double(zeros(1));
            timing_matrix = double(zeros(1,counter));
            binary_matrix = zeros(size(labeled_mask, 1), size(labeled_mask, 2), 2);
            binary_matrix(:,:,1) = positive_image;
            binary_matrix(:,:,2) = labeled_mask;
            
            %iterate over all the images
            for k=1:counter
                cur_frame = imread(frame_paths{k});
                
                cur_time = str2double(frame_times{k});
                timing_matrix(1,k) = cur_time;
                
                disp(['   [FRAME ', num2str(k),'] ', frame_times{k}]);

                %Convert the image to a grayscale image
                if (size(cur_frame, 3) > 1)
                    cur_frame = rgb2gray(cur_frame(:,:,1:3));
                end

                %Resize the image and convert to dobule for gaussian filtering and then normalized
                cur_frame = imresize(cur_frame, [std_img_size, NaN]);

                %Calculate the image feature vectors
                cur_frame_feat = image_feature(cur_frame);
                
                if(k == 1)
                    data_matrix = double(zeros(size(cur_frame_feat,1), size(cur_frame_feat,2), counter, size(cur_frame_feat, 3)));
                end
                
                %Write to ouput the results from the frame interpolation method
                for y=1:size(cur_frame_feat, 1)
                    for x=1:size(cur_frame_feat, 2)
                        if(positive_image(y,x) == 1)
                            data_matrix(y,x,k,:) = cur_frame_feat(y,x,:);
                        end
                    end
                end
            end
            
            %Save the datafile
            save(strtrim(data_out), 'data_matrix');
            save(strtrim(time_out), 'timing_matrix');
            save(strtrim(labeled_out), 'binary_matrix');
        end
        
        %Save the list of names that were condensed into a list
        save(filename_data, 'names_matrix');
        
        e = cputime - t;
        disp(['Time to build dataset (min): ', num2str(e / 60.0)]);
    catch Ex
        disp('-----Stack Errors-----');
        for i=1:length(Ex.stack)
            disp(Ex.stack(i));
        end
        error(Ex.message);
    end
end

function [out] = pad_out_string(in)
    max_len = 100;
    temp_out = blanks(max_len);
    if(size(in,2) < max_len)
        temp_out(1:size(in,2)) = in;
    end
    out = temp_out;
end