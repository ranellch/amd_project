function build_dataset_vessels(gabor_bool, lineop_bool)
    %constant for standard image sizes
    std_img_size = 768;
    
    lineop_len = 15;
    lineop_angcnt = 12;
    
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
    filename_input = 'vessel_draw.dataset';
    filename_gabor = 'vessel_gabor.mat';
    filename_lineop = 'vessel_lineop.mat';

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
    addpath('../intensity normalization')

    t = cputime;   
 
    %Get the images already run in the 
    mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');
    try
        %Open the file to determine which images to use for training 
        fid = fopen(filename_input, 'r');
        paths = textscan(fid,'%q %d %q %*[^\n]');
        fclose(fid);
        
        numimages = size(paths{1}, 1);
        
        %Make sure that all images and paths exist
        for k=1:numimages
            pid = char(paths{1}{k});
            eye = char(paths{2}{k});
            time = num2str((paths{3}(k)));
            
            image_exists = get_pathv2(pid, eye, time, 'original');
            image_real = imread(image_exists);
            if isempty(image_real)
                disp(['original image for ', pid, ' ', eye, ' ', time, ' not found'])
                return
            end
            
            vessel_image = get_pathv2(pid, eye, time, 'vessels');
            image_real_vessel = imread(vessel_image);
            if isempty(image_real_vessel)
                disp(['vessel map for ', pid, ' ', eye, ' ', time, ' not found'])
                return
            end
        end
       
        %Open the gabor output file for writing 
        if(gabor_bool == 1) 
             file_obj = matfile(filename_gabor,'Writable',true);
        end
        
        %Open the line operator file for writing, create lineop object
        if(lineop_bool == 1)
            file_obj = matfile(filename_lineop, 'Writable', true);
            lineop_obj = line_operator(lineop_len, lineop_angcnt);
        end
        file_obj.dataset = [];
        
        %Iterate over all images to use for training 
        for k=1:numimages
                pid = char(paths{1}{k});
                time = num2str((paths{2}(k)));
                eye = char(paths{3}{k});
                vessel_image = get_pathv2(pid, eye, time, 'vessels');

                %Get the vesselized image and convert it to a binary image
                vesselized_img = imread(vessel_image);
                if(size(vesselized_img, 3) > 1)
                    vesselized_img = rgb2gray(vesselized_img);
                end
                vesselized_img = crop_footer(vesselized_img);
                vesselized_img_binary = imresize(vesselized_img, [std_img_size, std_img_size]);

                %Get the original image 
                original_img = imread(get_pathv2(pid, time, eye, 'original'));

                %Pre-process
                if (size(original_img, 3) > 1)
                    original_img = rgb2gray(original_img);
                end
                original_img = crop_footer(original_img);
                original_img = imresize(original_img, [768 768]);
                original_img = gaussian_filter(original_img);
                [original_img, ~] = smooth_illum3(original_img,0.7);
                original_img = imcomplement(original_img);

                %Run Gabor, save max at each scale, normalize via zero_m_unit_std 
                if(gabor_bool == 1)  
                    bigimg = padarray(original_img, [50 50], 'symmetric');
                    fimg = fft2(bigimg);
                    k0x = 0;
                    k0y = 3;
                    epsilon = 4;
                    step = 10;
                    orig_wavelets = [];
                    for a = [1 2 3 4 5]
                        trans = maxmorlet(fimg, a, epsilon, [k0x k0y], step);
                        trans = trans(51:(50+sizey), (51:50+sizex));
                        orig_wavelets = cat(3, orig_wavelets, zero_m_unit_std(trans));
                    end
                end
            
                disp(['Extracting Info: ', pid, '(', time, ') Ref: ', vessel_image]);

                if (lineop_bool == 1)                
                    %Build lineop feature vectors
                    orig_lineops = zeros([size(original_img) 3]);
                    for y=1:size(original_img,1)
                        for x=1:size(original_img,2)
                            orig_lineops(y,x,:) = lineop_obj.get_fv(original_img,y,x);
                        end
                    end
                    %normalize features
                    for i = 1:3
                        orig_lineops(:,:,i) = zero_m_unit_std(orig_lineops(:,:,i));
                    end
                end
                
                %Save feature vectors for current image in .mat file generated above
                [nrows,~] = size(file_obj, 'dataset');
                file_obj.dataset(nrows+1:nrows+numel(original_img),1:size(feature_vectors,2)+1) = [vesselized_img_binary(:), feature_vectors];
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

function array = matstack2array(matstack) 
%Reshapes a 3D image into a numpixels x length(featurevector) array. 
%Featurevectors are arranged as a list of pixels organized in the same way as if you use the colon operator
%on a 2D image (I(:))

array = zeros(size(matstack,1)*size(matstack,2),size(matstack,3));
for x = 1:size(matstack,2)
    for y = 1:size(matstack,1)
        
        
