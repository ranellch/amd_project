function build_dataset_vessels()
    filename_input = 'vessel_draw.dataset';
    filename_gabor = 'gabor.classifier';
    filename_lineop = 'lineop.classifier';

    addpath(genpath('../Test Set'));
    addpath('..');
    
    %Get the images already run in the 
    mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    try
        %Open the file to determine which images to use for training 
        fid = fopen(filename_input, 'r');
        paths = textscan(fid,'%q %d %q %*[^\n]');
        fclose(fid);
       
        %Open the output files for writing 
        fout = fopen(filename_gabor, 'at');
        flineop = fopen(filename_lineop, 'at');       

        %Iterate over all images to use for training 
        for k=1:size(paths, 1)
            pid = char(paths{k,1});
            time = num2str((paths{k,2}));
            vessel_image = char(paths{k,3});
            
            %Get the vesselized image and convert it to a binary image
            vesselized_img = imread(['vessel_draw/', vessel_image]);
            vesselized_img = rgb2gray(vesselized_img);
            vesselized_img_binary = im2bw(vesselized_img,1);
            for y=1:size(vesselized_img, 1)
                for x=1:size(vesselized_img, 2)
                    if(vesselized_img(y,x) < 255)
                        vesselized_img_binary(y,x) = 1;
                    else
                        vesselized_img_binary(y,x) = 0;
                    end
                end
            end
            
            %Get the original image and perform a gabor wavelet transformation
            original_img = imread(get_path(pid, time));
            orig_wavelets = apply_gabor_wavelet(original_img, 0);
                              
            %Init some of the variables for the building of svm machine
            random_sample = 1;
            border_ignore = 5;
            grouping_one = 0;
            grouping_zero = 0;
            
            %For each pixel build a classifier
            for y=1:size(orig_wavelets,1)
                for x=1:size(orig_wavelets,2)
                    %Get the gabor wavelet feature vector
                    feature_vector_gabor=zeros(size(orig_wavelets, 3), 1);
                    for wave=1:size(orig_wavelets, 3)
                        feature_vector_gabor(wave, 1) = orig_wavelets(y,x,wave);
                    end

                    %Get the line operator feature vector
                    feature_vector_lineop = line_operator(original_img, y, x, 15, 8)';
 
                    %Get the grouping for this particular pixel
                    grouping = 0;
                    if(y <= size(vesselized_img_binary, 1) && x <= size(vesselized_img_binary, 2))
                        if(vesselized_img_binary(y,x) == 1)
                            grouping = 1;
                        end
                    end
                    
                    %Ignore the border and then either grouping is one or is some proportion 
                    if(x > border_ignore && x < (size(orig_wavelets,2) - border_ignore) && ...
                       y > border_ignore && y < (size(orig_wavelets,1) - border_ignore) && ...
                       (grouping == 1 || random_sample == 4))
                        %Write to the output file the gabor wavelet string
                        feature_string_gabor=feature_to_string(feature_vector_gabor);
                        fprintf(fout, '%d,%s\n', grouping, feature_string_gabor);

                        %Write to the output file the line operator string
                        feature_string_lineop=feature_to_string(feature_vector_lineop);
                        fprintf(flineop, '%d %s\n', grouping, feature_string_lineop);

                        random_sample = 1;
                        if(grouping == 1)
                            grouping_one=grouping_one+1;
                        else
                            grouping_zero=grouping_zero+1;
                        end
                    else
                        random_sample = random_sample + 1;
                    end
                end
            end
        end
        
        fclose(fout);
        fclose(flineop);
    catch err
        disp(err.message);
    end
    
    disp(['Ones: ', num2str(grouping_one), ' - Zeros: ', num2str(grouping_zero)]);
end
