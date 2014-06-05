function [accuracies, precisions ,sens] = optimize_vessels()
        addpath(genpath('../ML Library'))
        addpath(genpath('../libsvm-3.18'))
        
        t = cputime;
        %Get gabor wavelet feature vectors
        filename_gabor = 'vessel_gabor.mat';
        gabor_file = matfile(filename_gabor);
        variable_data_gabor =  gabor_file.dataset;
        
        %Disp some informaiton to the user
        ep = cputime - t;
        disp(['Time to load gabor features (min): ', num2str(ep / 60.0)]);

%         %Build the vessel classifier
%         vessel_gabor_classifier = NaiveBayes.fit(variable_data_gabor, variable_categories_gabor);
%         save('vessel_gabor_classifier.mat', 'vessel_gabor_classifier');
        
        t = cputime;
        %Get orthogonal line operator feaure vectors
        filename_lineop = 'vessel_lineop.mat';
        lineop_file = matfile(filename_lineop);
        variable_data_lineop =  lineop_file.dataset;
        
        %Disp some informaiton to the user
        ep = cputime - t;
        disp(['Time to load lineop features (min): ', num2str(ep / 60.0)]);
        
        %get category for every pixel
        categories = lineop_file.classes;
        
%         %Build the vessel classifier
%         vessel_lineop_classifier = NaiveBayes.fit(variable_data_lineop, variable_categories_lineop);
%         save('vessel_lineop_classifier.mat', 'vessel_lineop_classifier');
%         

	%Combine features, write to text for libsvm 
    combined_matrices = [variable_data_gabor, variable_data_lineop];
    libsvmwrite('vessel_training.dataset',categories,sparse(combined_matrices));
    
    training_matrix = combined_matrices(1:20:end,:);
    training_labels = categories(1:20:end,:);
%     %Create subset for training
%     system('python ..\libsvm-3.18\tools\subset.py vessel_training.dataset 500000 vessel_training.subset vessel_testing.dataset');
% %      system('..\libsvm-3.18\windows\svm-scale -s vessel_training.subset.range vessel_training.subset > vessel_training.subset.scale');
%     [training_labels, training_matrix] = libsvmread('vessel_training.subset');
    
    %Scale all features to [0 1] (x'=(x-mi)/(Mi-mi))
    %find max and min of each column
    mins = min(training_matrix);
    maxs = max(training_matrix);
    
    %scale each column
    for i = 1:size(training_matrix,2)
        training_matrix(:,i) = (training_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
    end
    
%     %Create subset for testing
%     system('python ..\libsvm-3.18\tools\subset.py vessel_testing.dataset 500000 vessel_testing.subset');
%     [testing_labels, testing_matrix] = libsvmread('vessel_testing.subset');

    testing_matrix = combined_matrices(2:20:end,:);
    testing_labels = categories(2:20:end);
    
   %scale each column
    for i = 1:size(testing_matrix,2)
        testing_matrix(:,i) = (testing_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
    end
    
    accuracies = [];
    precisions = [];
    sens = [];
    for ep = [0.01 0.05 0.1 0.5]
        t = cputime;
        disp('Building SVM classifier...Please Wait')
    % 	[~, vessel_combined_classifier] = adaboost('train', combined_matrices, categories, itt);
    %     vessel_combined_classifier = libsvmtrain(label_vector, instance_matrix, '-t 0 -m 1000 -e 0.01');
        classifier =  train(training_labels, sparse(training_matrix), ['-q -s 2 -e ' num2str(ep)]);
        
         %Disp some informaiton to the user
         e = cputime - t;
         disp(['Time to build classifier (min): ', num2str(e / 60.0)]);

         %Test classifier          
         class_estimates = libpredict(testing_labels, sparse(testing_matrix), classifier);
         accuracy = sum(class_estimates == testing_labels)/numel(testing_labels);
         precision = sum(class_estimates==1 & testing_labels==1)/sum(class_estimates==1);
         sen = sum(class_estimates == 1 & testing_labels==1)/sum(testing_labels==1);
         disp (['For ep = ', num2str(ep), ', Accuracy = ', num2str(accuracy), ' Precision = ', num2str(precision), ' Sensitivity = ', num2str(sen)]);
         sens = [sens; sen];
         accuracies = [accuracies; accuracy];
         precisions = [precisions; precision];

    end
         
end

