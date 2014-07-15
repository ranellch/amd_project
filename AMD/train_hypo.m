function train_hypo()
    if ispc
        addpath(genpath('..\libsvm-3.18'))
    else
        addpath(genpath('../libsvm-3.18'))
    end

    t = cputime;

    filename = 'hypo_training_data.mat';

    data_file = matfile(filename);

    try
        
                disp('======================Creating Pixelwise Texture Classifier======================');
                
                 instance_matrix = data_file.dataset;
                 label_vector = data_file.pixel_classes;
                 
                %Downsample to get less bias towards the negative samples
                 pos_cutoff = .1;
                [instance_matrix, label_vector] = downsample(instance_matrix, label_vector, pos_cutoff);

                %Get the minumum for each columns
                mins = min(instance_matrix);
                maxs = max(instance_matrix);
                scaling_factors = [mins; maxs];

                %scale each column
                for i = 1:size(instance_matrix,2)
                    instance_matrix(:,i) = (instance_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
                end

                disp('Building SVM classifier...Please Wait')

                classifier =  libsvmtrain(labeled_vector, sparse(instance_matrix), '-s 2');
                
                save('hypo_classifier.mat','classifier', 'scaling_factors'); 
                
 
    catch e
        disp('Unable to train classifier on training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Train Classifier Time (sec): ', num2str(e)]);
end
