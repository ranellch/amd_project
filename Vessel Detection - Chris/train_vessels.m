function train_vessels()
        addpath(genpath('../ML Library'))
        addpath(genpath('../libsvm-3.18'))
        
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
        categories = lineop_file.classes;
        
%         %Build the vessel classifier
%         vessel_lineop_classifier = NaiveBayes.fit(variable_data_lineop, variable_categories_lineop);
%         save('vessel_lineop_classifier.mat', 'vessel_lineop_classifier');
%         

	%Combine features, write to text for libsvm 
    combined_matrices = [variable_data_gabor, variable_data_lineop];
    libsvmwrite('vessel_training.dataset',categories,sparse(combined_matrices));
    
    %Create subset of 100,000 vectors, scale
    system('python ..\libsvm-3.18\tools\subset.py vessel_training.dataset 100000 vessel_training.subset');
    system('..\libsvm-3.18\windows\svm-scale -s vessel_training.subset.range vessel_training.subset > vessel_training.subset.scale');
    [label_vector, instance_matrix] = libsvmread('vessel_training.subset.scale');
    
    t = cputime;
    disp('Building SVM classifier...Please Wait')
% 	[~, vessel_combined_classifier] = adaboost('train', combined_matrices, categories, itt);
    vessel_combined_classifier = libsvmtrain(label_vector, instance_matrix, '-c 0.5 -g 8');
	save('vessel_combined_classifier.mat', 'vessel_combined_classifier');
    
     %Disp some informaiton to the user
     e = cputime - t;
     disp(['Time to build classifier (min): ', num2str(e / 60.0)]);
         
end

