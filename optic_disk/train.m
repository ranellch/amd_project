function train()
    filename = 'train_text.classifier';
    filename_intenstiy = 'train_intensity.classifier';
    
    %Run through the file and get the variables for texture classification
    disp('======================Texture Classifier======================');
    [text_variables, text_categories] = run_through_file(filename);
    
    text_prediction_bayesstruct = NaiveBayes.fit(text_variables, text_categories, 'Distribution', 'mn');
    save('text_prediction_bayesstruct.mat', 'text_prediction_bayesstruct');
    
    try
        text_prediction_svmstruct = svmtrain(text_variables, text_categories);
        save('text_prediction_svmstruct.mat', 'text_prediction_svmstruct');
    catch
        disp('Unable to train svm classifier on texture training set!');
    end
    
    %Get the variables for intensity classification
    disp('======================Intensity Classifier======================');
    [int_variables, int_categories] = run_through_file(filename_intenstiy);
    
    int_prediction_bayesstruct = NaiveBayes.fit(int_variables, int_categories);
    save('int_prediction_bayesstruct.mat', 'int_prediction_bayesstruct');
    
    try
        int_prediction_svmstruct = svmtrain(int_variables, int_categories);
        save('int_prediction_svmstruct.mat', 'int_prediction_svmstruct');
    catch
        disp('Unable to train svm classifier on intensity training set!');
    end
end

function [variables, categories] = run_through_file(filename)
    %Count the number of lines
    fid = fopen(filename);
    tline = fgets(fid);
    lines = 0;
    while ischar(tline)
        lines = lines + 1;
        tline = fgets(fid);
    end
    fclose(fid);

    %Count the number of varaibles per line
    lines_length = zeros(lines, 1);

    fid = fopen(filename);
    tline = fgets(fid);
    cur_line = 0;
    while ischar(tline)
        cur_line = cur_line + 1;
        comma_index = strfind(tline, ',');
        cur_index = comma_index(1, 2);
        for x=3:size(comma_index, 2)
            next_index = comma_index(1, x);
            numsubstr = tline(cur_index + 1:next_index - 1);
            lines_length(cur_line) = lines_length(cur_line) + 1;
            cur_index = next_index;
        end

        last_one = tline(cur_index + 1:size(tline, 2));
        lines_length(cur_line) = lines_length(cur_line) + 1;

        tline = fgets(fid);
    end
    fclose(fid);
    
    %Build empty svm variables array
    unique_variables_count = unique(lines_length);
    variables = zeros(lines, unique_variables_count(1));
    categories = zeros(lines, 1);
    svm_zero = 0;
    svm_one = 0;

    fid = fopen(filename);
    tline = fgets(fid);
    cur_line = 0;
    number_of_nan=0;
    while ischar(tline)
        cur_line = cur_line + 1;
        comma_index = strfind(tline, ',');

        %Get the category of this images HOG
        category = tline(comma_index(1, 1) + 1:comma_index(1, 2));
        categories(cur_line, 1) = str2double(category);

        if categories(cur_line) == 0
            svm_zero = svm_zero + 1;
        else
            svm_one = svm_one + 1;
        end

        %Loop through and get all the variables
        cur_index = comma_index(1, 2);
        cur_variable = 0;
        for x=3:size(comma_index, 2)
            cur_variable = cur_variable + 1;
            next_index = comma_index(1, x);
            numsubstr = tline(cur_index + 1:next_index - 1);
            number_read = str2double(numsubstr);
            if(~isnan(number_read))
                variables(cur_line, cur_variable) = number_read;
            else
                variables(cur_line, cur_variable) = 0;
                number_of_nan=number_of_nan+1;

            end
            cur_index = next_index;
        end

        cur_variable = cur_variable + 1;
        last_one = tline(cur_index + 1:size(tline, 2));
        variables(cur_line, cur_variable) = str2double(last_one);

        tline = fgets(fid);
    end
    fclose(fid);

	%Message to user information about training
    disp(['Number of Nans: ', num2str(number_of_nan)]);
    disp([num2str(lines), ' Training Images with ', num2str(unique_variables_count), ' Unique Variables']);
    disp(['Number of positive image: ', num2str(svm_one), ' - Number of negative images: ', num2str(svm_zero)]);
end
