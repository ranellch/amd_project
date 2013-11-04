function train_vessels()
    %Open the file and get the file handle
    filename = 'gabor.classifier';
    fid = fopen(filename);
    
    %Initialize the variables for counting the matricies
    line_count = 1;
    variable_count = 0;
    
    %Get the first line of the file
    tline = fgetl(fid);
    if(isnumeric(tline) && tline == -1)
        disp(['Check the contents of ', filename, ' it appears to be empty!']);
        return;
    end
    
    %Count the number of variables
    splitline = strsplit(tline, ',');
    variable_count = length(splitline);
        
    while ischar(tline)
        tline = fgetl(fid);
        if(ischar(tline))
            if(length(strsplit(tline,',')) == variable_count)
                line_count = line_count + 1;
            else
                disp('Line variable counts do not match!');
            end
        end
    end
    
    fclose(fid);
    
    disp(['In ', filename, ' Line Count: ', num2str(line_count), ' Variable Count: ', num2str(variable_count)]);
    
    %Declare and initialize array for classifier
    variable_categories = zeros(line_count, 1);
    variable_data = zeros(line_count, variable_count - 1);
    positive_count = 0;
    negative_count = 0;
    
    fid = fopen(filename);
    
    tline = fgetl(fid);
    while ischar(tline)
        splitline = strsplit(tline, ',');
        variable_categories(line_count, 1) = str2double(splitline(1));
        if(variable_categories(line_count, 1) == 1)
            positive_count = positive_count + 1;
        else
            negative_count = negative_count + 1;
        end
        for i=2:length(splitline);
            variable_data(line_count, i-1) = str2double(splitline(i));
        end
        line_count = line_count + 1;
        tline = fgetl(fid);
    end
    
    fclose(fid);
    
    disp(['Done loading Positive: ', num2str(positive_count),' - Negative: ', num2str(negative_count)]);

    vessel_classifier = NaiveBayes.fit(variable_data, variable_categories);
    save('vessel_classifier.mat', 'vessel_classifier');
end
