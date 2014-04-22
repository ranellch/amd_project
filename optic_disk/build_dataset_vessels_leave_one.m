function build_dataset_vessels_leave_one(gabor_bool, lineop_bool, paths)
    %constant for standard image sizes
    std_img_size = 768;
    
    lineop_len = 15;
    lineop_angcnt = 8;
    
    numimages = size(paths{1},1);
    
    %Test the values of the input variables for this function
    if((gabor_bool == 0 || gabor_bool == 1) && ...
       (lineop_bool == 0 || lineop_bool == 1))
        if((gabor_bool == 0 && lineop_bool == 0) || ...
           (gabor_bool == 1 && lineop_bool == 1))
            error('You must select one and only one feature to build training set.');
        end
    else
        error('Input variables must be the value 0 or 1.');
    end
    
    %Disp to user the current operation about to be done
    if(gabor_bool == 1)
        disp('Building the Gabor Wavelet Dataset');
    elseif(lineop_bool == 1)
        disp('Building the Line Operator Dataset');
    end

    %Filename constants
    filename_gabor = 'vessel_gabor.classifier';
    filename_lineop = 'vessel_lineop.classifier';

    %Remove gabor file is already exists
    if(gabor_bool == 1 && exist(filename_gabor, 'file') == 2)
        delete(filename_gabor);
    end

    %Remove lineop file if already exists
    if(lineop_bool == 1 && exist(filename_lineop, 'file') == 2)
        delete(filename_lineop);
    end

    %Add paths for the running of this function
    addpath(genpath('../Test Set'));
    addpath('..');
    addpath('vessel_draw');

    t = cputime;   
 
    %Get the images already run in the 
    mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    try
        
        %Make sure that all images and paths exist
        for k=1:numimages
            pid = char(paths{1}{k});
            time = num2str((paths{2}(k)));
            vessel_image = char(paths{3}{k});
            
            image_exists = get_path(pid, time);
            image_real = imread(image_exists);
            
            image_real_vessel = imread(vessel_image);
        end
       
        %Open the gabor output file for writing 
        if(gabor_bool == 1) 
            fout = fopen(filename_gabor, 'w');
        end
        
        %Open the line operator file for writing
        if(lineop_bool == 1)
            flineop = fopen(filename_lineop, 'w'); 
            lineop_obj = line_operator(lineop_len, lineop_angcnt);
        end
        
        %Iterate over all images to use for training 
        for k=1:numimages
            pid = char(paths{1}{k});
            time = num2str((paths{2}(k)));
            vessel_image = char(paths{3}{k});
            
            %Get the vesselized image and convert it to a binary image
            vesselized_img = imread(vessel_image);
            vesselized_img = crop_footer(vesselized_img);
            if(size(vesselized_img, 3) > 1)
                vesselized_img = rgb2gray(vesselized_img);
            end
            vesselized_img_binary = imresize(vesselized_img, [std_img_size, std_img_size]);
            
            %Get the original image and perform a gabor wavelet transformation
            original_img = imread(get_path(pid, time));
            original_img = crop_footer(original_img);
            original_img = imresize(original_img, [std_img_size, std_img_size]);
            original_img = gaussian_filter(original_img);
            if(gabor_bool == 1)
                orig_wavelets = apply_gabor_wavelet(original_img, 0);
            end
            
            disp(['Extracting Info: ', pid, '(', time, ') Ref: ', vessel_image]);
            
            %Init some of the variables for the building of the classifier
            random_sample = 1;
            border_ignore = 5;
            grouping_one = 0;
            grouping_zero = 0;
            
            %For each pixel build a classifier
            for y=1:size(original_img,1)
                for x=1:size(original_img,2)
                    if(gabor_bool == 1)
                        %Get the gabor wavelet feature vector
                        feature_vector_gabor=zeros(size(orig_wavelets, 3), 1);
                        for wave=1:size(orig_wavelets, 3)
                            feature_vector_gabor(wave, 1) = orig_wavelets(y,x,wave);
                        end
                    end

                    if(lineop_bool == 1)
                        %Get the line operator feature vector
                        feature_vector_lineop = lineop_obj.get_fv(original_img,y,x);
                    end

                    %Get the grouping for this particular pixel
                    grouping = 0;
                    if(y <= size(vesselized_img_binary, 1) && x <= size(vesselized_img_binary, 2))
                        if(vesselized_img_binary(y,x) == 1)
                            grouping = 1;
                        end
                    end

                    %Ignore the border and then either grouping is one or is some proportion 
                    if(x > border_ignore && x < (size(original_img,2) - border_ignore) && ...
                       y > border_ignore && y < (size(original_img,1) - border_ignore) && ...
                       (grouping == 1 || random_sample >= 4))
        
                        %Write to the output file the gabor wavelet string
                        if(gabor_bool == 1)
                            feature_string_gabor=feature_to_string(feature_vector_gabor);
                            fprintf(fout, '%d,%s\n', grouping, feature_string_gabor);
                        end

                        %Write to the output file the line operator string
                        if(lineop_bool == 1)  
                            feature_string_lineop=feature_to_string(feature_vector_lineop);
                            fprintf(flineop, '%d,%s\n', grouping, feature_string_lineop);
                        end

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
        
        %Close the appropiate files when neccessary
        if(gabor_bool == 1)
            fclose(fout);
        end
        
        if(lineop_bool == 1)
            fclose(flineop); 
        end
    catch err
        disp(err.message);
        disp([getfield(err.stack, 'file')]);
        disp(['Error on line: ', num2str(getfield(err.stack, 'line'))]);
    end
    
    disp(['Ones: ', num2str(grouping_one), ' - Zeros: ', num2str(grouping_zero)]);
    e = cputime - t;
    disp(['Time to build dataset (min): ', num2str(e / 60.0)]);

end
