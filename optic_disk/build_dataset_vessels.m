function [grouping_one, grouping_zero] = build_dataset_vessels()
    filename = 'gabor.classifier';

    addpath(genpath('../Test Set'));
    addpath('..');
    
    %Get the xml document for the databsae
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');
    
    %Get the images already run in the 
    mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    try
        %Open the file 
        fid = fopen('vessel_draw.dataset', 'r');
        paths = textscan(fid,'%q %d %q %*[^\n]');
        fclose(fid);
        
        fout = fopen(filename, 'at');
        
        for x=1:size(paths, 1)
            pid = char(paths{x,1});
            time = num2str((paths{x,2}));
            vessel_image = char(paths{x,3});
            
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
            [orig_wavelets, comb] = apply_gabor_wavelet(original_img);
            
            figure(1), imshow(comb);
            figure(2), imshow(vesselized_img_binary);
                        
            every_third = 1;
            border_ignore = 5;
            grouping_one = 0;
            grouping_zero = 0;
            
            %For each pixel build a classifier
            for y=1:size(orig_wavelets,1)
                for x=1:size(orig_wavelets,2)
                    feature_vector=zeros(size(orig_wavelets, 3), 1);
                    sum = 0;
                    for wave=1:size(orig_wavelets, 3)
                        feature_vector(wave, 1) = orig_wavelets(y,x,wave);
                        sum = sum + orig_wavelets(y,x,wave);
                    end
                    
                    %Get the grouping for this particular pixel
                    grouping = 0;
                    if(y <= size(vesselized_img_binary, 1) && x <= size(vesselized_img_binary, 2))
                        if(vesselized_img_binary(y,x) == 1)
                            grouping = 1;
                        end
                    end
                    
                    %Ignore the border and then either grouping is one or
                    %is every third
                    if(x > border_ignore && x < (size(orig_wavelets,2) - border_ignore) && ...
                       y > border_ignore && y < (size(orig_wavelets,1) - border_ignore) && ...
                       (grouping == 1 || every_third == 3))
                        %Write to the output file the feature string
                        feature_string=feature_to_string(feature_vector);
                        fprintf(fout, '%d,%s\n', grouping, feature_string);
                        every_third = 1;
                        if(grouping == 1)
                            grouping_one=grouping_one+1;
                        else
                            grouping_zero=grouping_zero+1;
                        end
                    else
                        every_third = every_third + 1;
                    end
                end
            end
        end
        
        fclose(fout);
    catch err
        disp(err.Message);
    end
end