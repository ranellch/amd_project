function train_vessels()
        addpath(genpath('../liblinear-1.94'))
        
        t = cputime;
        %Get feaure vectors
        filename = 'vessel_data.mat';
        data_file = matfile(filename);
        instance_matrix =  data_file.dataset;
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time to load features (min): ', num2str(e / 60.0)]);
        
        %get category for every pixel
        label_vector = data_file.classes;
                 
    
    %Try to get at least 20% positive instances by discarding a certain
    %percentage of negatives
    [instance_matrix, label_vector] = downsample(instance_matrix, label_vector, 0.3);
    
    disp(['Number of Positive Instances: ', num2str(sum(label_vector==1)), ' Number of Negative Instances: ', ... 
        num2str(sum(label_vector==0)), ' Total: ', num2str(numel(label_vector))]);  
    
    %Scale all features to [0 1] (x'=(x-mi)/(Mi-mi))
     %find max and min of each column
    mins = min(instance_matrix);
    maxs = max(instance_matrix);
    scaling_factors = [mins; maxs];
    
    %scale each column
    for i = 1:size(instance_matrix,2)
        instance_matrix(:,i) = (instance_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
    end
         
    t = cputime;
    disp('Building SVM classifier...Please Wait')

% 	[~, vessel_combined_classifier] = adaboost('train', combined_matrices, categories, itt);
%     vessel_combined_classifier = libsvmtrain(label_vector, instance_matrix, '-t 0 -m 1000 -e 0.01');
%     options_struct = statset('Display','iter','MaxIter',1000000);
	vessel_combined_classifier =  train(label_vector, sparse(instance_matrix), '-s 2 -B 1');

    save('vessel_combined_classifier.mat', 'vessel_combined_classifier', 'scaling_factors');
    
     %Disp some informaiton to the user
     e = cputime - t;
     disp(['Time to build classifier (min): ', num2str(e / 60.0)]);
     
end

