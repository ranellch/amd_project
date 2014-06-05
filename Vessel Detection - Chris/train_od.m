function train_od()
    t = cputime;

    filename = 'od_classify.mat';
    
    %Run through the file and get the variables for texture classification
    disp('======================Texture Classifier======================');
    od_text_file = matfile(filename);
    od_text_variables = od_text_file.dataset;
    od_text_classes = od_text_file.classes;

    try
        od_classify_svmstruct = svmtrain(od_text_variables(1:32:end,:), od_text_classes(1:32:end), 'kktviolationlevel', 0.5, 'boxconstraint', 0.8);
        save('od_classify_svmstruct.mat', 'od_classify_svmstruct');
    catch e
        disp('Unable to train svm classifier on texture training set!');
        disp(getReport(e));
    end
    
    e = cputime - t;
    disp(['Optic Disc Train Classifier Time (min): ', num2str(e/60.0)]);
end
