function train_insig()
    addpath('..')
    if ispc
         addpath(genpath('..\liblinear-1.94'))
    else
         addpath(genpath('../liblinear-1.94'))
    end

    t = cputime;

    filename = 'insig_training_data.mat';

    data_file = matfile(filename);

    try
                
                 instance_matrix = data_file.dataset;
                 label_vector = data_file.classes;
                 
                %Downsample positives to get less bias towards normal
                %retina
                 neg_cutoff = .4;
                [instance_matrix, label_vector] = downsample(instance_matrix, ~label_vector, neg_cutoff);
                label_vector = double(~label_vector);

                %Get the minumum for each columns
                mins = min(instance_matrix);
                maxs = max(instance_matrix);
                scaling_factors = [mins; maxs];

                %scale each column
                for i = 1:size(instance_matrix,2)
                    instance_matrix(:,i) = (instance_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
                end

                disp('Building SVM classifier...Please Wait')

                classifier =  train(label_vector, sparse(instance_matrix), '-s 2 -B 1');
                
                save('insig_classifier.mat','classifier', 'scaling_factors'); 
                
 
    catch e
        disp('Unable to train classifier on training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Train Classifier Time (min): ', num2str(e/60.0)]);
end
