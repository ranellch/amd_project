function train_vessels()
    addpath(genpath('../ML Library'))
    itt = 30;

    t = cputime;
    %Get gabor wavelet feature vectors
    filename_gabor = 'vessel_gabor.mat';
    gabor_file = matfile(filename_gabor);
    variable_data_gabor =  gabor_file.dataset;

    %Disp some informaiton to the user
    e = cputime - t;
    disp(['Time to load gabor features (min): ', num2str(e / 60.0)]);

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
        
	%Create a combined classifier
    combined_matrices = [variable_data_gabor, variable_data_lineop];
    
    t = cputime;
    disp('Building SVM classifier...Please Wait')
% 	[~, vessel_combined_classifier] = adaboost('train', combined_matrices, categories, itt);
    vessel_combined_classifier = svmtrain(combined_matrices(1:32:end,:), categories(1:32:end),'kktviolationlevel',0.5, 'boxconstraint', 0.8);
	save('vessel_combined_classifier.mat', 'vessel_combined_classifier');
    
    %Disp some informaiton to the user
    e = cputime - t;
    disp(['Time to build classifier (min): ', num2str(e / 60.0)]);
         
end

