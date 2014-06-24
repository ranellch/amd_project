function train_roi()
    if ispc
        addpath(genpath('..\liblinear-1.94'))
    else
        addpath(genpath('../liblinear-1.94'))
    end

    t = cputime;

    filename = 'roi_classify.mat';
    
    %Run through the file and get the variables for texture classification
    disp('======================Texture Classifier======================');
    od_file = matfile(filename);
    roi_variables = od_file.dataset;
    roi_classes = od_file.classes;

    try
        %Downsample to get less bias towards the negative samples
        [roi_downsample_variables, roi_downsample_classes] = downsample_roi(roi_variables, double(roi_classes));
        
        %Get the minumum for each columns
        mins = min(roi_downsample_variables);
        maxs = max(roi_downsample_variables);
        scaling_factors = [mins; maxs];
        
        %scale each column
        for i = 1:size(roi_downsample_variables,2)
            roi_downsample_variables(:,i) = (roi_downsample_variables(:,i)-mins(i))/(maxs(i)-mins(i));
        end
                
        disp('Building SVM classifier...Please Wait')
        
        roi_classify_svmstruct =  train(roi_downsample_classes, sparse(roi_downsample_variables), '-s 2 -B 1');
    
        save('roi_classify_svmstruct.mat', 'roi_classify_svmstruct', 'scaling_factors');
    catch e
        disp('Unable to train svm classifier on texture training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['ROI Train Classifier Time (sec): ', num2str(e)]);
end
    