function find_np(pid, eye, time, varargin)
    images_path = '../Test Set/';
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arguments'));
    end
    
    std_img_size = 768;
    
    %Load the classifier struct for this bad boy
    model = load('np_combined_classifier.mat');
    scaling_factors = model.scaling_factors;
    classifier = model.np_combined_classifier;

    %Add the location of the external scripts that we are going to call
    addpath('xmlfunc');
    addpath('auxfunc');
    
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
    
    scatter_plot = double(zeros(1));
    
    %Iterate over the files
    for k=1:count
        try         
            %Get the current path and load the image
            cur_path = path{k};
            original_image = imread(cur_path);
            
            %Convert the image to a grayscale image
            if (size(original_image, 3) > 1)
                original_image = original_image(:,:,1:3);
                original_image = rgb2gray(original_image);
            end

            %Resize the image and convert to dobule for gaussian filtering and then normalized
            original_image = imresize(original_image, [std_img_size, NaN]);
            original_image = im2double(original_image);
            original_features = image_feature(original_image);
            
            %If first iteration then build the scatter plot array
            if(k == 1)
                scatter_plot = double(zeros(size(original_features, 1), size(original_features, 2), count, size(original_features, 3) + 1));
            end
            
            %Copy results into the interpolation array
            for y=1:size(original_features,1)
                for x=1:size(original_features,2)
                    scatter_plot(y,x,k,1) = str2double(times{k});
                    scatter_plot(y,x,k,2:end) = original_features(y,x,:);
                end
            end
            
            
            %Calculate the image feature vectors
            feature_image = matstack2array(original_features);
            
            %Scale vectors
            for i = 1:size(feature_image,2)
                fmin = scaling_factors(1,i);
                fmax = scaling_factors(2,i);
                feature_image(:,i) = (feature_image(:,i)-fmin)/(fmax-fmin);
            end

            t = cputime;

            %Do pixelwise classification
            binary_img = zeros(size(original_image));
            binary_img(:) = libpredict(zeros(length(feature_image),1), sparse(feature_image), classifier, '-q');
            
            %Output how long it took to do this
            e = cputime-t;
            if(debug == 1 || debug == 2)
                disp(['Classify (min): ', num2str(double(e) / 60.0)]);
            end

            %Mask out the roi and the vessels
            binary_mask = apply_mask(binary_mask, roi_mask, 0);
            binary_mask = apply_mask(binary_mask, vessel_mask, 1);
        catch e
            for i=1:size(e.stack, 1)
                disp(e.stack(i));
            end
            error(e.message);
        end
    end
end