function analyze_hypo(rebuild_classifier)
    addpath('..');
    addpath(genpath('../Test Set'))

    if ~isdir('./results')
        mkdir('./results');
    end

    results_file = './results/analyze_results.txt';

    if(rebuild_classifier == 1)
        %Build machine learning models
        build_dataset_hypo();
		train_hypo();
    end

    %Get the images to include from this list
    fid = fopen('hypo_draw.testing', 'r');
    includes = textscan(fid,'%s %s %d %*[^\n]');
    fclose(fid);

    numimages = size(includes{1}, 1);

    fout = fopen(results_file, 'w');
    
    disp('----------Results----------');
    line = 'Img, Sensitivity, Specificity, Accuracy, Precision,';
    fprintf(fout, '%s\n', line);
    
    
    %Run through the images and make sure that they exist
    for k=1:numimages
       pid = char(includes{1}{k});
       eye = char(includes{2}{k});
       time = num2str((includes{3}(k)));
       
       image_exists = get_pathv2(pid, eye, time, 'original');
       if isempty(image_exists)
           error([pid, ' ', eye, ' ', time, 'original not found in XML'])
       else
           disp(image_exists)
       end
       imread(image_exists);
            
       AMD_image = get_pathv2(pid, eye, time, 'AMD');
       if isempty(od_image)
           error([pid, ' ', eye, ' ', time, ' AMD labeled image not found in XML'])
       else
           disp(od_image)
       end
       imread(od_image);
    end
    disp('All images valid.  Running tests')
    disp('-----------------------------');
    output_results = zeros(numimages, 5);
    od_notfound = 0;

    for k=1:numimages
        pid = char(includes{1}{k});
        eye = char(includes{2}{k});
        time = num2str(includes{3}(k));  
       
        %Get the original image 
        original_path = get_pathv2(pid, eye, time, 'original');
        original_img = im2double(imread(original_path));
        if(size(original_img, 3) > 1)
            original_img = rgb2gray(original_img);
        end
                
        %Get the image run by the algorithm
        calced_img= find_hypo(pid, eye, time, 1);
        imwrite(display_outline(original_img,calced_img,[1 0 0]), ['./results/',pid,'_',eye,'_',time,'-hypo.tif'], 'tiff');

        %Get the image snaked by hand
		AMD_image = imread(get_pathv2(pid, eye, time, 'AMD'));
		AMD_image = imresize(AMD_image,[768 768]);
        super_img = AMD_image(:,:,3) > AMD_image(:,:,1);
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
        
       %Write the results from this badboy
        output_results(k,1) = true_positive/total_positive_count; %sensitivity
        output_results(k,2) = true_negative/total_negative_count; %specificity
        output_results(k,3) = (true_positive+true_negative)/(total_positive_count+total_negative_count); %accuracy
        output_results(k,4) = true_positive/(true_positive+false_positive); %precision

        numline = num2str(output_results(k,1));
        for l=2:size(output_results,2)
                numline = [numline, ', ', num2str(output_results(k,l));];
            end
            line = [pid,' ', eye, ' (', time, '), ', numline];
        end
        disp(line);
        fprintf(fout, '%s\n', line);
        disp('--------------------------------------');
    end

    fprintf(fout, '%s\n', line);
    fclose(fout);

end