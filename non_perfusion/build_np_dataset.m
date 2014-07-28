function build_np_dataset(varargin)
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
    
    %Filename constants
    filename_input = 'np.training';
    filename_data = 'np_data.mat';
    images_path = '../Test Set/';
    addpath('illum');
    addpath('xmlfunc');
    addpath('auxfunc');
    
    %Remove file is already exists
    if exist(filename_data, 'file') == 2
        delete(filename_data);
    end
    
    t = cputime;
    
    try
        %Open the file to determine which images to use for training 
        fid = fopen(filename_input, 'r');
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
        
        %Open the output file for writing 
        file_obj = matfile(filename_data,'Writable',true);
        file_obj.dataset = [];
        file_obj.classes = [];
        file_obj.timestamps = [];
        
        %Iterate over all images to use for training 
        for i=1:numimages
            pid = char(paths{1}{i});
            eye = char(paths{2}{i});
            time = char(paths{3}(i));
                        
            %Get the current video to analyze
            [video_xml, directory] = get_video_xml(pid, eye, time, 'seq_path');
            addpath([images_path, directory]);
            [counter, paths, times] = get_images_from_video_xml(video_xml);
            
            %Display to the user the current video going to be analyzed
            disp(['[PID] ', pid, ' [Eye] ', eye, ' [Time] ', time, ' [# FRAMES] ', num2str(counter)]);
            
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
            
            imshow(labeled_mask);
            
            %Remove file is already exists
            filename_gabor = [pid, '_', eye, '_', time, '_gabor.mat'];
            [x_inter, interpolated_curves] = frame_interpolation(std_img_size, counter, times, paths, positive_image, filename_gabor);
        
            %Write to ouput the results from the frame interpolation method
            [nrows,~] = size(file_obj, 'dataset');
            next_row = nrows + 1;
            for y=1:size(interpolated_curves, 1)
                for x=1:size(interpolated_curves, 2)
                    if(positive_image(y,x) == 1)
                        file_obj.dataset(next_row, 1:size(interpolated_curves,3)) = interpolated_curves(y,x,:);
                        file_obj.timestamp(next_row, 1:size(x_inter,3)) = x_inter(:);
                        file_obj.class(next_row, 1) = labeled_mask(y,x);
                        next_row = next_row + 1;
                    end
                end
            end
                        
            
%             %Get the original image
%             original_path = get_image_xml(pid, eye, time, 'original');
%             original_image = imread(original_path);
% 
%             %Convert the image to a grayscale image
%             if (size(original_image, 3) > 1)
%                 original_image = original_image(:,:,1:3);
%                 original_image = rgb2gray(original_image);
%             end
% 
%             %Resize the image and convert to dobule for gaussian filtering and then normalized
%             original_image = imresize(original_image, [std_img_size, NaN]);
%                 
%             %Calculate the image feature vectors
%             feature_image = image_feature(original_image);
%             
%             %Save this data to the results datatable.
%             [nrows,~] = size(file_obj, 'dataset');
%             feature_vectors = matstack2array(feature_image);
%             file_obj.dataset(nrows+1:nrows+numel(original_image),1:size(feature_vectors,2)) = feature_vectors;
%             
%             label_vectors = matstack2array(labeled_image);
%             file_obj.classes(nrows+1:nrows+numel(original_image),1:size(label_vectors,2)) = label_vectors;
        end
        
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