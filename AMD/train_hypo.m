function train_hypo()
    addpath('..')
    if ispc
        addpath(genpath('..\libsvm-3.18'))
    else
        addpath(genpath('../libsvm-3.18'))
    end

    t = cputime;

    filename = 'hypo_training_data.mat';

    data_file = matfile(filename);

    try
                
                 instance_matrix = data_file.dataset;
                 label_vector = data_file.classes;
                 
                %Downsample to get less bias towards the negative samples
                 pos_cutoff = .5;
                [instance_matrix, label_vector] = downsample(instance_matrix, label_vector, pos_cutoff);
                
                %Downsample to 100000 points
                 indices = randperm(length(label_vector), 100000);
                 ds_instances = zeros(100000,size(instance_matrix,2));
                 ds_labels = zeros(100000,1);
                 count = 1;
                 for i = indices
                    ds_instances(count,:) = instance_matrix(i,:);
                    ds_labels(count) = label_vector(i);
                    count = count + 1;
                 end
                 instance_matrix = ds_instances;
                 label_vector = ds_labels;
                 clear ds_instances
                 clear ds_labels

                %Get the minumum for each columns
                mins = min(instance_matrix);
                maxs = max(instance_matrix);
                scaling_factors = [mins; maxs];

                %scale each column
                for i = 1:size(instance_matrix,2)
                    instance_matrix(:,i) = (instance_matrix(:,i)-mins(i))/(maxs(i)-mins(i));
                end

                disp('Building SVM classifier...Please Wait')

                classifier =  libsvmtrain(label_vector, sparse(instance_matrix), '-b 1');
                
                save('hypo_classifier.mat','classifier', 'scaling_factors'); 
                
 
    catch e
        disp('Unable to train classifier on training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Train Classifier Time (min): ', num2str(e/60.0)]);
end
