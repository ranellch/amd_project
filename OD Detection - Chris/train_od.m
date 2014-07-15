function train_od(classifier)
    if ispc
        addpath(genpath('..\liblinear-1.94'))
    else
        addpath(genpath('../liblinear-1.94'))
    end

    t = cputime;

    filename = 'od_training_data.mat';

    od_file = matfile(filename);

    try
        
        switch classifier
            
            case 'pixel'
                disp('======================Creating Pixelwise Texture Classifier======================');
                
                 pixel_variables = od_file.pixel_features;
                 pixel_classes = od_file.pixel_classes;
                 
                %Downsample to get less bias towards the negative samples
                fraction_pos = .1;
                [od_downsample_variables, od_downsample_classes] = downsample(pixel_variables, double(pixel_classes),fraction_pos);

                %Get the minumum for each columns
                mins = min(od_downsample_variables);
                maxs = max(od_downsample_variables);
                scaling_factors = [mins; maxs];

                %scale each column
                for i = 1:size(od_downsample_variables,2)
                    od_downsample_variables(:,i) = (od_downsample_variables(:,i)-mins(i))/(maxs(i)-mins(i));
                end

                disp('Building SVM classifier...Please Wait')

                pixel_classifier =  train(od_downsample_classes, sparse(od_downsample_variables), '-s 2');
                
                save('od_classifiers.mat','pixel_classifier', 'scaling_factors'); 
                
            case 'region'
                
                disp('======================Creating OD Region Classifier=============================');
                
                region_variables = od_file.region_features;
                region_classes = od_file.region_classes;
        
                disp('Building Naive Bayes classifier...Please Wait')

                region_classifier = NaiveBayes.fit(region_variables, region_classes, 'Distribution','kernel');

                save('od_classifiers.mat', 'region_classifier','-append');
        end
    catch e
        disp('Unable to train classifier on training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Train Classifier Time (sec): ', num2str(e)]);
end
