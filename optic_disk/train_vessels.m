function train_vessels()
        %Train classifier using gabor wavelets
        t = cputime;
        filename_gabor = 'vessel_gabor.classifier';
        [variable_data_gabor, variable_categories_gabor] = readin_classfile(filename_gabor);

        %Normalize the data from the training set
        variable_data_gabor = normalize_data(variable_data_gabor);

        %Build the vessel classifier
        vessel_gabor_classifier = NaiveBayes.fit(variable_data_gabor, variable_categories_gabor);
        save('vessel_gabor_classifier.mat', 'vessel_gabor_classifier');
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time (min): ', num2str(e / 60.0)]);
 
        %Train classifier using orthogonal line operators
        t = cputime;
        filename_lineop = 'vessel_lineop.classifier';
        [variable_data_lineop, variable_categories_lineop] = readin_classfile(filename_lineop);

        %Normalize the data from the training set
        variable_data_lineop = normalize_data(variable_data_lineop);
        
        %Build the vessel classifier
        vessel_lineop_classifier = NaiveBayes.fit(variable_data_lineop, variable_categories_lineop);
        save('vessel_lineop_classifier.mat', 'vessel_lineop_classifier');
        
        %Disp some informaiton to the user
        e = cputime - t;
        disp(['Time (min): ', num2str(e / 60.0)]);

	%Try to create a combined classifier
	if(size(variable_categories_lineop, 1) == size(variable_categories_gabor, 1))
		combined_matricies = horzcat(variable_data_gabor, variable_data_lineop);
                combined_categories = zeros(size(variable_categories_lineop,1), 1);
                for cat=1:size(variable_categories_gabor,1)
                    if(variable_categories_lineop(cat,1) == variable_categories_gabor(cat,1))
                        combined_categories(cat,1) = variable_categories_gabor(cat,1);
                    else
                        error('Your categories labels does not match and therefore cannot create combined matrix!');
                    end
                end
		vessel_combined_classifier = NaiveBayes.fit(combined_matricies, combined_categories);
		save('vessel_combined_classifier.mat', 'vessel_combined_classifier');
	else
		disp('UNABLE to create combined matricies becuase these categories do not match!');
	end
end

function [dataout] = normalize_data(data)
    %Get descriptive statistics of the values of the variables
    themean = mean(data);
    stddev = std(data);

    %Create output array to hold the results
    dataout = zeros(size(data, 1), size(data, 2));

    %Apply normalization factor to all values of the variables
    for x=1:size(data, 1)
        for z=1:size(data, 2)
            dataout(x,z) = (data(x,z) - themean(z)) / stddev(z);
        end
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

