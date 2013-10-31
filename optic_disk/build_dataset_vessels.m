function build_dataset_vessels()
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
            orig_wavelets = apply_gabor_wavlet(original_img);
            
            imshow(orig_wavelets(:,:,1));
            return;
            
            %For each pixel build a classifier
            for y=1:size(orig_wavelets, 1)
                for x=1:size(orig_wavelets, 2)
                    feature_vector=zeros(size(orig_wavelets, 3), 1);
                    for wave=1:size(orig_wavelets, 3)
                        feature_vector(wave, 1) = orig_wavelets(y,x,wave);
                    end
                    
                    %Get the grouping for this particular pixel
                    grouping = 0;
                    if(y <= size(vesselized_img, 1) && x <= size(vesselized_img, 2))
                        if(vesselized_img(y,x) == 1)
                            grouping = 1;
                        end
                    end
                    
                    %Write to the output file the feature string
                    feature_string=feature_to_string(feature_vector);
                    fprintf(fout, '%d, %s\n', grouping, feature_string);
                end
            end
        end
        
        fclose(fout);
    catch
        error('Unknown!');
    end
end