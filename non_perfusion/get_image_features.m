function [data_matrix, timing_matrix, binary_matrix, names_matrix_line] = get_image_features(pid, eye, time, std_img_size, get_label)
    %Create the output matfile name base
    filename_output = [pid, '_', eye, '_', time];

    %Create the data out file
    data_out = pad_out_string([filename_output, '.mat']);

    %Create the time out file
    time_out = pad_out_string([filename_output, '_time.mat']);

    %Create the labeled matrix out
    labeled_out = pad_out_string([filename_output, '_labeled.mat']);
    
    %Save the filename to the output file
    names_matrix_line = cellstr([data_out; time_out; labeled_out]);
            
    %Get the current video to analyze
    [video_xml, directory] = get_video_xml(pid, eye, time, 'seq_path');
    images_path = '../Test Set/';
    addpath([images_path, directory]);
    [counter, frame_paths, frame_times] = get_images_from_video_xml(video_xml);
    
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

    %Create all the matricies for holding the results
    binary_layer = 1;
    if(get_label == 1)
        binary_layer = binary_layer + 1;
    end
    binary_matrix = zeros(size(positive_image, 1), size(positive_image, 2), binary_layer);
    binary_matrix(:,:,1) = positive_image;
    
    %Get the labeled image and process it into a mask
    if(get_label == 1)
        [labeled_path, labeled_directory] = get_video_xml(pid, eye, time, 'labeled_path');
        addpath([images_path, labeled_directory]);
        labeled_mask = imread(labeled_path);
        labeled_mask = imresize(labeled_mask, [std_img_size, NaN]);
        labeled_mask = process_labeled(labeled_mask);
        binary_matrix(:,:,2) = labeled_mask;
    end
    
    %Run the feature extraction on each image
    [data_matrix, timing_matrix] = video_feature(frame_paths, frame_times, counter, positive_image, std_img_size);
end

function [out] = pad_out_string(in)
    max_len = 100;
    temp_out = blanks(max_len);
    if(size(in,2) < max_len)
        temp_out(1:size(in,2)) = in;
    end
    out = temp_out;
end
