function train_od()
    filename = 'od_texture.classifier';
    
    %Run through the file and get the variables for texture classification
    disp('======================Texture Classifier======================');
    [text_variables, text_categories] = readin_classfile(filename);
    
    od_text_bayesstruct = NaiveBayes.fit(text_variables, text_categories);
    save('od_text_bayesstruct.mat', 'od_text_bayesstruct');
    
    try
        maxiter_inc = statset('MaxIter', 30000);
        od_text_vmstruct = svmtrain(text_variables, text_categories, 'options', maxiter_inc, 'Method', 'QP');
        save('od_text_vmstruct.mat', 'od_text_vmstruct');
    catch
        disp('Unable to train svm classifier on texture training set!');
    end
end

function [variable_data, variable_categories] = readin_classfile(filename)
    fid = fopen(filename);
    
    %Initialize the variables for counting the matricies
    line_count = 0;
    variable_count = 0;
    
    %Get the first line of the file
    tline = fgetl(fid);
    if(isnumeric(tline) == 1 && tline == -1)
        disp(['Check the contents of ', filename, ' it appears to be empty!']);
        return;
    else
        disp(['Reading: ', filename]);
    end
    
    %Count the number of variables
    splitline = strsplit(tline, ',');
    variable_count = length(splitline);
    
    %Count the number of lines in the file
    while ischar(tline)
        line_count=line_count+1;
        if(length(strsplit(tline, ',')) ~= variable_count)          
             error(['Line(', num2str(line_count),') variable counts do not match!']);
        end
        
        tline=fgetl(fid);
    end
    
    %Close the file
    fclose(fid);
    
    %Show to the user the filename, line count, and variable count
    disp(['In ', filename, ' Line Count: ', num2str(line_count), ' - Variable Count: ', num2str(variable_count - 1)]);
    
    %Declare and initialize array for classifier
    variable_categories = zeros(line_count, 1);
    variable_data = zeros(line_count, variable_count - 1);
    current_count=1;
    positive_count = 0;
    negative_count = 0;
    
    %Iterate over the file and get all the numbers for this badboy
    fid = fopen(filename);
    
    tline = fgetl(fid);
    while ischar(tline)
        splitline = strsplit(tline, ',');
        
        %Get the category of the following feature vector
        variable_group = str2double(splitline(1));
        if(variable_group == 1)
            positive_count=positive_count + 1;
        else
            negative_count=negative_count + 1;
        end
        variable_categories(current_count, 1) = variable_group;
        
        %Get the values of the information at differeing orientations and scale
        for i=2:length(splitline);
            the_val = str2double(splitline(i));
            if(isnan(the_val) == 1)
                the_val = 0;
            end
            variable_data(current_count, i-1) = the_val;
        end

        current_count=current_count+1;
        
        tline=fgetl(fid);
    end
    
    fclose(fid);
    
    %Display some stats from reading of the file
    disp(['Done loading...Positive: ', num2str(positive_count),' - Negative: ', num2str(negative_count)]);
end

