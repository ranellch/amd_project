function analyze_vessels_compare(rebuild_classifier)
    addpath('vessel_draw');
    addpath('..');
    
    results_file = 'analyze_results.txt';
    
    if(rebuild_classifier == 1)
        %Build training set
        build_dataset_vessels(1,0);
        build_dataset_vessels(0,1);

        %Train the classifier
        train_vessels();
    end
    
    %Open the file to test all of this against
    test_file = 'vessel_draw_test.dataset';
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
    paths = textscan(fid,'%q %d %q %*[^\n]');
    numimages = size(paths{1},1);
    fclose(fid);
    
    %Run through the images and make sure that they exist
    for k=1:numimages
        pid = char(paths{1}{k});
        time = num2str((paths{2}(k)));
        vessel_image = char(paths{3}{k});
            
        %See if original image exists
        img_path_exists = get_path(pid, time);
        
        %Get the image traced by hand
        super_img = imread(vessel_image);
    end
    
    output_results = zeros(numimages, 8, 3);
        
    
    %Iterate over all images to use for testing
    for k=1:numimages
        pid = char(paths{1}{k});
        time = num2str((paths{2}(k)));
        vessel_image = char(paths{3}{k});
       
        %Get the image run by the algorithm
        [gabor_bin, lineop_bin, combined_bin] = find_vessels(pid, time, 0);
        
        imwrite(gabor_bin,['./results/', pid, '-', time '-gabor vessels','.tif'],'tiff');
        imwrite(lineop_bin,['./results/', pid, '-', time '-lineop vessels','.tif'],'tiff');
        imwrite(combined_bin,['./results/', pid, '-', time '-combined vessels','.tif'],'tiff');
        
        %Calculate some stats about the quality of each pixel classification
        output_results(k, :, 1) = determine_stats(gabor_bin, vessel_image, pid, time);
        output_results(k, :, 2) = determine_stats(lineop_bin, vessel_image, pid, time);
        output_results(k, :, 3) = determine_stats(combined_bin, vessel_image, pid, time);
    end

   %Disp to user the results from this badboy
    fout = fopen(results_file, 'w');
    
    disp('----------Results----------');
    line = 'Img, True Positive, True Negative, False Positive, False Negative, Total Positive Count, Total Negative Count, Accuracy, Precision';
    disp(line);
    fprintf(fout, '%s', line);
    test = cell(1,3);
    test{1} = 'gabor';
    test{2} = 'lineop';
    test{3}='combined';
    for k=1:numimages
        pid = char(paths{1}{k});
        time = num2str((paths{2}(k)));       
        for j = 1:3      
            numline = num2str(output_results(k,1,j));
            for l=2:size(output_results,2)
                numline = [numline, ', ', num2str(output_results(k,l,j));];
            end

           line = [pid, '(', time, ') - ',test{j}, ' ', numline];
            disp(line);
            fprintf(fout, '%s\n', line);
        end
    end
    
    fclose(fout);
end
