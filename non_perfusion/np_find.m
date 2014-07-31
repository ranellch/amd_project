function np_find(pid, eye, time, varargin)
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
    x_values = model.x_values;
    classifier = model.np_combined_classifier;

    %Add the location of the external scripts that we are going to call
    addpath('xmlfunc');
    addpath('auxfunc');
            
    disp('------Feature Extraction-----');
    try
        %Run the feature extraction on each image
        [data_matrix, timing_matrix, binary_matrix, ~] = get_image_features(pid, eye, time, std_img_size, 0);
         
    catch e
        for i=1:size(e.stack, 1)
            disp(e.stack(i));
        end
        error(e.message);
    end
    disp('------End Feature Extraction-----');
    
    disp('------Interpolate Features-----');
    %Interpolate the features for a frame set
    try
        [interpolated_curves] = interpolate_time_curves(x_values, timing_matrix, data_matrix, binary_matrix);
    catch e
        for i=1:size(e.stack, 1)
            disp(e.stack(i));
        end
        error(e.message);
    end
    disp('------End Interpolate Features-----');
    
    %Create the resultant matrix of feature vectors
    feature_count = size(interpolated_curves, 4) * size(x_values, 2);
    observation_count = numel(find(binary_matrix == 1));
    instance_matrix = double(zeros(observation_count, feature_count));
    cur_observation = 1;
    
    %Copy the y,x coordinates into the matrix
    for y=1:size(interpolated_curves, 1);
        for x=1:size(interpolated_curves, 2);
            if(binary_matrix(y,x) == 1)
                for z=1:size(interpolated_curves, 3)
                    %Calculate the start and end index of current features
                    expanded_features = size(x_values, 2);
                    sindex = ((z-1) * expanded_features)+1;
                    eindex = sindex + expanded_features - 1;

                    %Load the interpolated values into the appropiate place in the feature vector
                    cur_index = 1;
                    for k=sindex:eindex
                        instance_matrix(cur_observation, k) = interpolated_curves(y,x,z,cur_index);
                        cur_index = cur_index + 1;
                    end
                end

                %Move onto the next observation
                cur_observation = cur_observation + 1;
            end
        end
    end
        
    %Scale the feature vectors
    for i = 1:size(instance_matrix, 2)
        fmin = scaling_factors(1, i);
        fmax = scaling_factors(2, i);
        instance_matrix(:, i) = (instance_matrix(:, i) - fmin) / (fmax - fmin);
    end

    %Start timing clock
    t = cputime;

    %Do pixelwise classification
    classification = libpredict(zeros(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
    cur_class_index = 1;
    
    %Return the classification to the image pixels
    binary_image = zeros(size(original_image,1), size(original_image,2));
    for y=1:size(original_image,1)
        for x=1:size(original_image,2)
            if(binary_matrix(y,x) == 1)
                binary_image(y,x) = classification(cur_class_index, 1);
                cur_class_index = cur_class_index + 1;
            end
        end
    end
    
    %Output how long it took to do this
    e = cputime-t;
    if(debug == 1 || debug == 2)
        disp(['Classify (min): ', num2str(double(e) / 60.0)]);
    end
    
    figure, imshow(binary_image);
end
