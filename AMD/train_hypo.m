function train_hypo()
    if ispc
        addpath(genpath('..\libsvm-3.18'))
    else
        addpath(genpath('../libsvm-3.18'))
    end

    t = cputime;

    filename = 'hypo_training_data.mat';

    od_file = matfile(filename);

    try
        
                disp('======================Creating Pixelwise Texture Classifier======================');
                
                 pixel_variables = od_file.pixel_features;
                 pixel_classes = od_file.pixel_classes;
                 
                %Downsample to get less bias towards the negative samples
                [od_downsample_variables, od_downsample_classes] = downsample_od(pixel_variables, double(pixel_classes));

                %Get the minumum for each columns
                mins = min(od_downsample_variables);
                maxs = max(od_downsample_variables);
                scaling_factors = [mins; maxs];

                %scale each column
                for i = 1:size(od_downsample_variables,2)
                    od_downsample_variables(:,i) = (od_downsample_variables(:,i)-mins(i))/(maxs(i)-mins(i));
                end

                disp('Building SVM classifier...Please Wait')

                pixel_classifier =  train(od_downsample_classes, sparse(od_downsample_variables), '-s 2 -B 1');
                
                save('od_classifiers.mat','pixel_classifier', 'scaling_factors'); 
                
 
    catch e
        disp('Unable to train classifier on training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Train Classifier Time (sec): ', num2str(e)]);
end
