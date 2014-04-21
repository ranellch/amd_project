function analyze_vessels_leave_one()
    addpath('vessel_draw');
    addpath('..');
    
    results_file = 'analyze_results.txt';
    
    %get how many vessel images we have
    filename_input = 'vessel_draw.dataset';
    fid = fopen(filename_input, 'r');
    paths = textscan(fid,'%q %d %q %*[^\n]');
    fclose(fid);
    numimages = size(paths{1},1);
    
    %Loop through and test classifiers using the "leave one out" method
    for k = 1:numimages
        
        %Specify test image info
        pid = char(paths{1}{k});
        time = num2str((paths{2}(k)));
        vessel_image = char(paths{3}{k});
        
        %Specify training images
         rowindex=ones(numimages,1);
         rowindex(k)=0;
         training_paths = cell(1,3);
         training_paths{1} = paths{1}(rowindex~=0);
         training_paths{2} = paths{2}(rowindex~=0);
         training_paths{3} = paths{3}(rowindex~=0);
        
        %Build training set
        build_dataset_vessels_leave_one(1,0, training_paths);
        build_dataset_vessels_leave_one(0,1, training_paths);

        %Train the classifier
        train_vessels();

        %Test all of this against left out image
        output_results = zeros(size(paths, 1), 8);

        %Get the image run by the algorithm
        calced_img = find_vessels(pid, time, 0);

        %Get the image traced by hand
        super_img = imread(vessel_image);
        total_positive_count = 0;
        total_negative_count = 0;
        for y=1:size(super_img,1)
            for x=1:size(super_img,2)
                if(super_img(y,x) == 1)
                    total_positive_count = total_positive_count + 1;
                else
                    total_negative_count = total_negative_count + 1;
                end
            end
        end

        %Check the sizing of the images compared to each other
        if(size(calced_img, 1) ~= size(super_img, 1) || size(calced_img, 2) ~= size(super_img, 2))
            disp(['Images Not Same Size: ', pid, ' - ', time]);
            disp([num2str(size(super_img, 1)), ',', num2str(size(super_img, 2)), ' : ', num2str(size(calced_img, 1)), ',', num2str(size(calced_img, 2))]);
            continue;
        end

        %Get some statistics about the quality of the pixel classification
        total_count = 0;
        true_positive = 0;
        true_negative = 0;
        false_positive = 0;
        false_negative = 0;
        for y=1:size(calced_img,1)
            for x=1:size(calced_img,2)
                if(super_img(y,x) == 1 && calced_img(y,x) == 1)
                    true_positive = true_positive + 1;
                elseif(super_img(y,x) == 0 && calced_img(y,x) == 0)
                    true_negative = true_negative + 1;
                elseif(super_img(y,x) == 0 && calced_img(y,x) == 1)
                    false_positive = false_positive + 1;
                elseif(super_img(y,x) == 1 && calced_img(y,x) == 0)
                    false_negative = false_negative + 1;
                end
                total_count = total_count + 1;
            end
        end

        if(total_count ~= (total_negative_count + total_positive_count))
            disp(['total_count (', num2str(total_count),') and total_negative + total_positive_count (', num2str(total_negative_count + total_positive_count),') Do not match']);
            continue;
        end

        output_results(k,1) = true_positive;
        output_results(k,2) = true_negative;
        output_results(k,3) = false_positive;
        output_results(k,4) = false_negative;
        output_results(k,5) = total_positive_count;
        output_results(k,6) = total_negative_count;
        output_results(k,7) = (true_positive+true_negative)/(total_positive_count+total_negative_count); %accuracy
        output_results(k,8) = true_positive/(true_positive+false_positive); %precision
        disp('--------------------------------------');
    end


    fout = fopen(results_file, 'w');
    
    disp('----------Results----------');
    line = 'Img, True Positive, True Negative, False Positive, False Negative, Total Positive Count, Total Negative Count, Accuracy, Precision';
    disp(line);
    fprintf(fout, '%s', line);
    %Disp to user the results from this badboy
    for k=1:numimages
        pid = char(paths{1}{k});
        time = num2str((paths{2}(k)));
        
        numline = num2str(output_results(k,1));
        for l=2:size(output_results,2)
            numline = [numline, ', ', num2str(output_results(k,l));];
        end
        
        line = [pid, '(', time, '), ', numline];
        disp(line);
        fprintf(fout, '%s\n', line);
    end
    
    fclose(fout);
end
