function analyze_amd(rebuild_classifier)
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
		build_dataset_hyper();
		train_hyper();
    end

    %Get the images to include from this list
    fid = fopen('amd_draw.testing', 'r');
    includes = textscan(fid,'%s %s %d %*[^\n]');
    fclose(fid);

    numimages = size(includes{1}, 1);

    fout = fopen(results_file, 'w');
    
    disp('----------Results----------');
    line = 'Img, Sensitivity HYPO, Specificity HYPO, Accuracy HYPO, Precision HYPO, Sensitivity HYPER, Specificity HYPER, Accuracy HYPER, Precision HYPER';
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
            
       amd_image = get_pathv2(pid, eye, time, 'AMD');
       if isempty(amd_image)
           error([pid, ' ', eye, ' ', time, ' AMD labeled image not found in XML'])
       else
           disp(amd_image)
       end
       imread(amd_image);
    end
    disp('All images valid.  Running tests')
    disp('-----------------------------');
    output_results = zeros(numimages, 8);
    od_notfound = 0;

    for k=1:numimages
        pid = char(includes{1}{k});
        eye = char(includes{2}{k});
        time = num2str(includes{3}(k));  
       
        %Get the original image 
        original_path = get_pathv2(pid, eye, time, 'original');
        original_img = im2double(imread(original_path));
        original_img = imresize(original_img,[768 768]);
        original_img = im2double(original_img);
                
        %Get the images run by the algorithm
        [hypo, hyper] = find_amd(pid, eye, time, 1);
		temp = display_outline(original_img,hypo,[1 0 0]);
		final = display_outline(temp,hyper,[1 1 0]);
        imwrite(final, ['./results/',pid,'_',eye,'_',time,'-amd.tif'], 'tiff');

        %Get the hypo image labeled by hand
		amd_image = imread(get_pathv2(pid, eye, time, 'AMD'));
		amd_image = imresize(amd_image,[768 768]);
		
        super_img = amd_image(:,:,3) > amd_image(:,:,1);
        total_positive_count = numel(super_img(super_img==1));
        total_negative_count = numel(super_img(super_img==0));


        %Get some statistics about the quality of the hypo pixel classification
        total_count = 0;
        true_positive = 0;
        true_negative = 0;
        false_positive = 0;
        false_negative = 0;
        for y=1:size(hypo,1)
            for x=1:size(hypo,2)
                if(super_img(y,x) == 1 && hypo(y,x) == 1)
                    true_positive = true_positive + 1;
                elseif(super_img(y,x) == 0 && hypo(y,x) == 0)
                    true_negative = true_negative + 1;
                elseif(super_img(y,x) == 0 && hypo(y,x) == 1)
                    false_positive = false_positive + 1;
                elseif(super_img(y,x) == 1 && hypo(y,x) == 0)
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
		
		super_img = amd_image(:,:,1) > amd_image(:,:,2);
        total_positive_count = numel(super_img(super_img==1));
        total_negative_count = numel(super_img(super_img==0));
		
		%Get some statistics about the quality of the hyper pixel classification
        total_count = 0;
        true_positive = 0;
        true_negative = 0;
        false_positive = 0;
        false_negative = 0;
        for y=1:size(hyper,1)
            for x=1:size(hyper,2)
                if(super_img(y,x) == 1 && hyper(y,x) == 1)
                    true_positive = true_positive + 1;
                elseif(super_img(y,x) == 0 && hyper(y,x) == 0)
                    true_negative = true_negative + 1;
                elseif(super_img(y,x) == 0 && hyper(y,x) == 1)
                    false_positive = false_positive + 1;
                elseif(super_img(y,x) == 1 && hyper(y,x) == 0)
                    false_negative = false_negative + 1;
                end
                total_count = total_count + 1;
            end
        end
        
        if(total_count ~= (total_negative_count + total_positive_count))
            disp(['total_count (', num2str(total_count),') and total_negative + total_positive_count (', num2str(total_negative_count + total_positive_count),') Do not match']);
            continue;
        end
		
		output_results(k,5) = true_positive/total_positive_count; %sensitivity
        output_results(k,6) = true_negative/total_negative_count; %specificity
        output_results(k,7) = (true_positive+true_negative)/(total_positive_count+total_negative_count); %accuracy
        output_results(k,8) = true_positive/(true_positive+false_positive); %precision
        
       %Write the results from this badboy
        numline = num2str(output_results(k,1));
        for l=2:size(output_results,2)
                numline = [numline, ', ', num2str(output_results(k,l));];
        end
        line = [pid,' ', eye, ' (', time, '), ', numline];
        disp(line);
        fprintf(fout, '%s\n', line);
        disp('--------------------------------------');

    end
    fclose(fout);
end