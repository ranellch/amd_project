function train_od()
    addpath(genpath('../liblinear-1.94'))

    t = cputime;

    filename = 'od_classify.mat';
    
    %Run through the file and get the variables for texture classification
    disp('======================Texture Classifier======================');
    od_file = matfile(filename);
    od_variables = od_file.dataset;
    od_classes = od_file.classes;

    try
        %Downsample to get less bias towards the negative samples
        [od_downsample_variables, od_downsample_classes] = downsample(od_variables, double(od_classes));
        
        %Get the minumum for each columns
        mins = min(od_downsample_variables);
        maxs = max(od_downsample_variables);
        scaling_factors = [mins; maxs];
        
        %scale each column
        for i = 1:size(od_downsample_variables,2)
            od_downsample_variables(:,i) = (od_downsample_variables(:,i)-mins(i))/(maxs(i)-mins(i));
        end
                
        disp('Building SVM classifier...Please Wait')
        
        od_classify_svmstruct =  train(od_downsample_classes, sparse(od_downsample_variables), '-s 2 -B 1');
    
        save('od_classify_svmstruct.mat', 'od_classify_svmstruct', 'scaling_factors');
    catch e
        disp('Unable to train svm classifier on texture training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Optic Disc Train Classifier Time (sec): ', num2str(e)]);
end
