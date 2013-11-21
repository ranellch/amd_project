function train_vessels(gabor_bool, lineop_bool)
    if(gabor_bool == 1)
        %Train classifier using gabor wavelets
        t = cputime;
        filename_gabor = 'gabor.classifier';
        [variable_data, variable_categories] = readin_classfile(filename_gabor);
        
        %Build the vessel classifier
        gabor_vessel_classifier = NaiveBayes.fit(variable_data, variable_categories);
        save('gabor_vessel_classifier.mat', 'gabor_vessel_classifier');
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time (', filename_gabor, ') minutes: ', num2str(e / 60.0)]);
    end
 
    if(lineop_bool == 1)
        %Train classifier using orthogonal line operators
        t = cputime;
        filename_lineop = 'lineop.classifier';
        [variable_data, variable_categories] = readin_classfile(filename_lineop);

        %Get descriptive statistics of the values of the variables
        themean = mean(variable_data);
        stddev = std(variable_data);
        
        %Apply normalization factor to all values of the variables
        for x=1:size(variable_data, 1)
            for z=1:size(variable_data, 2)
                variable_data(x,z) = (variable_data(x,z) - themean(z)) / stddev(z);
            end
        end

        %Build the vessel classifier
        lineop_vessel_classifier = NaiveBayes.fit(variable_data, variable_categories);
        save('lineop_vessel_classifier.mat', 'lineop_vessel_classifier');
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time (', filename_lineop, ') minutes: ', num2str(e / 60.0)]);
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
        variable_group=str2double(splitline(1));
        if(variable_group == 1)
            positive_count=positive_count + 1;
        else
            negative_count=negative_count + 1;
        end
        variable_categories(current_count, 1) = variable_group;
        
        %Get the values of the information at differeing orientations and scale
        for i=2:length(splitline);
            variable_data(current_count, i-1) = str2double(splitline(i));
        end

        current_count=current_count+1;
        
        tline=fgetl(fid);
    end
    
    fclose(fid);
    
    %Display some stats from reading of the file
    disp(['Done loading...Positive: ', num2str(positive_count),' - Negative: ', num2str(negative_count)]);
end
