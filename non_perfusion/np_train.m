function np_train()
    addpath(genpath('../liblinear-1.94'))
    
    %Get list of matricies to collate
    filename = 'np_data.mat';
    data_file = load(filename);
    
    %Get the start time
    t = cputime;
    
    %Loop on timing values for each set of images
    maxmin = 0;
    minmax = 0;
    for i=1:size(data_file,2)
        %Show some useful output
        disp(['[TIMING] ', num2str(i), ' / ', num2str(size(data_file,2))]);
        
        %Open the time file
        time_file = data_file.names_matrix{2,i};
        time = load(time_file);
        
        %Find the max minumim time
        time_min = min(time.timing_matrix(:));
        if(time_min > maxmin || i == 1)
            maxmin = time_min;
        end
        
        %Find the min maximum time
        time_max = max(time.timing_matrix(:));
        if(time_max < minmax || i == 1)
            minmax = time_max;
        end
    end
    
    %Calculate the values of the overlapping region to interpolate
    step = 0.5;
    x_values = maxmin:step:minmax;
    
    %Some useful user information
    disp(['[MIN] ', num2str(maxmin), ' - [MAX] ', num2str(minmax), ' - [STEP] ', num2str(step), ' - [COUNT] ', num2str(size(x_values,2))]);
    disp('--------------------------------------');
    
    %Variables for outputting results
    observation_count = 0;
    feature_count = 0;
    instance_matrix = double(zeros(1));
    cur_observation = 1;
    label_vector = zeros(1);
    
    for i=1:size(data_file,2)
        %Get the mask for vessels/roi and the labeled binary image
        disp('[COUNTING] loading up and counting all the observations in all training sets');
        labeled = load(data_file.names_matrix{3,i});
        valid_pixels = labeled.binary_matrix(:,:,1);
        
        observation_count = observation_count + numel(find(valid_pixels == 1));
        disp(['     [OBS COUNT] ', num2str(observation_count)]);
    end
    disp('--------------------------------------');
    
    for i=1:size(data_file,2)
        %Show some useful output
        disp(['[INTERPOLATION] ', num2str(i), ' / ', num2str(size(data_file,2))]);

        %Get the mask for vessels/roi and the labeled binary image
        disp('[LOAD] Loading the labeled and the binary roi/vessel mask');
        labeled = load(data_file.names_matrix{3,i});
        valid_pixels = labeled.binary_matrix(:,:,1);
        labeled_pixels = labeled.binary_matrix(:,:,2);

        %Get the timing information for this frame set
        disp('[LOAD] Loading the frame timing information');
        time = load(data_file.names_matrix{2,i});

        %Load the features files and then interpolate all the values
        disp('[LOAD] Loading the frames features dataset');
        features = (data_file.names_matrix{1,i});
        
        %Do some error checking or initialize the output variables
        if(i == 1)
            feature_count = size(features.data_matrix, 4) * size(x_values,2);
            instance_matrix = double(zeros(observation_count, feature_count));
            label_vector = zeros(observation_count, 1);
        else
            if ((size(features.data_matrix, 4) * size(x_values, 2)) ~= feature_count)
                error('The features variables do not seem to match the initialized area');
            end
        end
        
        %Interpolate the features for a frame set
        [interpolated_curves] = interpolate_time_curves(x_values, time.timing_matrix, features.data_matrix, valid_pixels);
        
        %Write the results to the output file
        disp('[RESULTS] Formatting results into a feature vector label format');
        for y=1:size(interpolated_curves,1);
            for x=1:size(interpolated_curves,2);
                if(valid_pixels(y,x) == 1)
                    for z=1:size(interpolated_curves,3)
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

                    %Get the current pixels labels
                    label_vector(cur_observation, 1) = labeled_pixels(y,x);

                    %Move onto the next observation
                    cur_observation = cur_observation + 1;
                end
            end
        end
    end
    
    if((cur_observation - 1) ~= observation_count)
        error('Number of observations read and the number calculated do not match up!');
    end
    
    %Disp some informaiton to the user
    e = cputime - t;
    disp(['[TIME] To load and interpolate (min): ', num2str(e / 60.0)]);
    disp('--------------------------------------');
    
    %Scale all features to [0 1] (x'=(x-mi)/(Mi-mi)) 
    %   find max and min of each column
    mins = min(instance_matrix);
    maxs = max(instance_matrix);
    scaling_factors = [mins; maxs];
    
    %scale each column
    for i = 1:size(instance_matrix,2)
        instance_matrix(:,i) = (instance_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
    end
    
    %Downsample to prevent bias
    disp('[BIAS RATIO]');
    disp(['     INITIAL Pos: ', num2str(numel(find(label_vector == 1))), ' Neg: ', num2str(numel(find(label_vector == 0))), ' (Pos/Tot) = ', num2str(numel(find(label_vector == 1)) / numel(label_vector))]);
    [instance_matrix, label_vector] = np_downsample(instance_matrix, label_vector, 0.2);
    disp(['     AUGMENTED Pos: ', num2str(numel(find(label_vector == 1))), ' Neg: ', num2str(numel(find(label_vector == 0))), ' (Pos/Tot) = ', num2str(numel(find(label_vector == 1)) / numel(label_vector))]);

    %Start buildng the SVM classifier
    t = cputime;
    disp('[SVM] Building SVM classifier...Please Wait')

	np_combined_classifier =  train(label_vector, sparse(instance_matrix), '-s 2');

    save('np_combined_classifier.mat', 'np_combined_classifier', 'scaling_factors', 'x_values');
    
    %Disp some informaiton to the user
    e = cputime - t;
    disp(['[TIME] To build classifier (min): ', num2str(e / 60.0)]);
end