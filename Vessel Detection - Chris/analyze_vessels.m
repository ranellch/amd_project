function analyze_vessels(rebuild_classifier)
    addpath('..');
    addpath(genpath('../Test Set'))
    
    if ~isdir('.\results')
        mkdir('.\results');
    end
    
    results_file = '.\results\analyze_results.txt';
    
    if(rebuild_classifier == 1)
        %Build training set
        build_dataset_vessels(1,0);
        build_dataset_vessels(0,1);

        %Train the classifier
        train_vessels();
    end
    
    %Open the file with test images
    test_file = 'vessel_draw.testing';
    fid = fopen(test_file);
        
    %Get the first line of the file
    tline = fgetl(fid);
    if(isnumeric(tline) == 1 && tline == -1)
        disp(['Check the contents of ', test_file, ' it appears to be empty!']);
        return;
    else
        disp(['Reading: ', test_file]);
    end
    disp('-----------------------------');
    
    %Close the file
    fclose(fid);
    
    %Open the file to determine which images to use for testing 
    fid = fopen(test_file, 'r');
    paths = textscan(fid,'%q %q %d %*[^\n]');
    fclose(fid);
    
    numimages = size(paths{1}, 1);
    
    %Run through the images and make sure that they exist
    for k=1:numimages
       pid = char(paths{1}{k});
       eye = char(paths{2}{k});
       time = num2str((paths{3}(k)));
       
       image_exists = get_pathv2(pid, eye, time, 'original');
       imread(image_exists);
            
       vessel_image = get_pathv2(pid, eye, time, 'vessels');
       imread(vessel_image);
    end
    
    output_results = zeros(size(paths, 1), 4);
        
    
    %Iterate over all images to use for testing 
    for k=1:numimages
       pid = char(paths{1}{k});
       eye = char(paths{2}{k});
       time = num2str((paths{3}(k)));
       vessel_image = get_pathv2(pid, eye, time, 'vessels');
       
        %Get the original image 
        original_path = get_pathv2(pid, eye, time, 'original');
        original_img = imread(original_path);
        
        %Get the image run by the algorithm
        [calced_img,~] = find_vessels(pid, eye, time);
        imwrite(calced_img, ['.\results\',pid,'_',eye,'_',time,'-bin.tif'], 'tiff');
        
        %Get the image traced by hand
        super_img = imread(vessel_image);
        super_img = imresize(super_img, [768 768]);
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
       
        output_results(k,1) = true_positive/total_positive_count; %sensitivity
        output_results(k,2) = true_negative/total_negative_count; %specificity
        output_results(k,3) = (true_positive+true_negative)/(total_positive_count+total_negative_count); %accuracy
        output_results(k,4) = true_positive/(true_positive+false_positive); %precision
        disp(output_results(k,:))
        disp('--------------------------------------');
    end

    fout = fopen(results_file, 'w');
    
    disp('----------Results----------');
    line = 'Img, Sensitivity, Specificity, Accuracy, Precision';
    disp(line);
    fprintf(fout, '%s\n', line);
    %Disp to user the results from this badboy
    for k=1:numimages
        pid = char(paths{1}{k});
        eye = char(paths{2}{k});
        time = num2str((paths{3}(k)));
        
        numline = num2str(output_results(k,1));
        for l=2:size(output_results,2)
            numline = [numline, ', ', num2str(output_results(k,l));];
        end
        
        line = [pid,' ', eye, ' (', time, '), ', numline];
        disp(line);
        fprintf(fout, '%s\n', line);
    end
    
    fclose(fout);
end
