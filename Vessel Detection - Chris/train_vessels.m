function train_vessels()
        addpath(genpath('../ML Library'))
        addpath(genpath('../libsvm-3.18'))
        addpath(genpath('../liblinear-1.94'))
        
        t = cputime;
        %Get gabor wavelet feature vectors
        filename_gabor = 'vessel_gabor.mat';
        gabor_file = matfile(filename_gabor);
        variable_data_gabor =  gabor_file.dataset;
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time to load gabor features (min): ', num2str(e / 60.0)]);

%         %Build the vessel classifier
%         vessel_gabor_classifier = NaiveBayes.fit(variable_data_gabor, variable_categories_gabor);
%         save('vessel_gabor_classifier.mat', 'vessel_gabor_classifier');
        
        t = cputime;
        %Get orthogonal line operator feaure vectors
        filename_lineop = 'vessel_lineop.mat';
        lineop_file = matfile(filename_lineop);
        variable_data_lineop =  lineop_file.dataset;
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time to load lineop features (min): ', num2str(e / 60.0)]);
        
        %get category for every pixel
        label_vector = lineop_file.classes;
                 

	%Combine features
    instance_matrix = [variable_data_gabor, variable_data_lineop];    
    
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

