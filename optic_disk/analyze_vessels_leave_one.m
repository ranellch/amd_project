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
    
    output_results = zeros(numimages, 8, 3);
    
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

     %--Test all of this against left out image----

        %Get the image run by the algorithm
        [gabor_bin, lineop_bin, combined_bin] = find_vessels(pid, time, 0);
            
        imwrite(gabor_bin,['./results/', pid, '-', time '-gabor vessels','.tif'],'tiff');
        imwrite(lineop_bin,['./results/', pid, '-', time '-lineop vessels','.tif'],'tiff');
        imwrite(combined_bin,['./results/', pid, '-', time '-combined vessels','.tif'],'tiff');
        
        %Calculate some stats about the quality of each pixel classification
        output_results(k, :, 1) = determine_stats(gabor_bin, vessel_img, pid, time);
        output_results(k, :, 2) = determine_stats(lineop_bin, vessel_img, pid, time);
        output_results(k, :, 3) = determine_stats(combined_bin, vessel_img, pid, time);
        
        %Disp to user the results from this badboy
    
        fout = fopen(results_file, 'a');
        
        disp('----------Results----------');
        line = 'Img, True Positive, True Negative, False Positive, False Negative, Total Positive Count, Total Negative Count, Accuracy, Precision';
        disp(line);
        if k==1
            fprintf(fout, '%s', line);
        end

        test = cell(1,3);
        test{1} = 'gabor';
        test{2} = 'lineop';
        test{3}='combined';

        
        for j = 1:3
            numline = num2str(output_results(k,1,j));
            for l=2:size(output_results,2)
                numline = [numline, ', ', num2str(output_results(k,l,j));];
            end

            line = [pid, '(', time, ') - ',test{j}, ' ', numline];
            disp(line);
            %update text file 
            fprintf(fout, '%s\n', line);
        end
        
        
        fclose(fout);

    end



end
