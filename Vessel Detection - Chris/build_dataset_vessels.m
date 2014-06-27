function build_dataset_vessels(gabor_bool, lineop_bool, varargin)
    debug = -1;
    imcomp = -1;
    if length(varargin) == 1
        imcomp = 'none';
        debug = varargin{1};
        valid_debug(debug);
    elseif length(varargin) == 2
        imcomp = varargin{1};
        valid_imcomp(imcomp);
        
        debug = varargin{2};
        valid_debug(debug);
    elseif isempty(varargin)
        debug = 1;
        imcomp = 'none';
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
    end

    %constant for standard image sizes
    std_img_size = 768;
    
    %Constants for the line operator
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
    if(gabor_bool == 1 && debug == 1)
        disp('Building the Gabor Wavelet Dataset');
    elseif(lineop_bool == 1 && debug == 1)
        disp('Building the Line Operator Dataset');
    end

    %Filename constants
    filename_input = 'vessel_dme.training';
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
    addpath(genpath('../intensity normalization'))

    t = cputime;   

    try
        %Open the file to determine which images to use for training 
        fid = fopen(filename_input, 'r');
        paths = textscan(fid,'%q %q %d %*[^\n]');
        fclose(fid);
        
        numimages = size(paths{1}, 1);
        
        try
        %Make sure that all images and paths exist
        for k=1:numimages
            pid = char(paths{1}{k});
            eye = char(paths{2}{k});
            time = num2str((paths{3}(k)));
            
            image_exists = get_pathv2(pid, eye, time, 'original');
            imread(image_exists);
            
            vessel_image = get_pathv2(pid, eye, time, 'vessels');
            imread(vessel_image);
        end
        catch E
            error(E.message);
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
                eye = char(paths{2}{k});
                time = num2str((paths{3}(k)));
                vessel_image = get_pathv2(pid, eye, time, 'vessels');

                %Get the vesselized image and convert it to a binary image
                vesselized_img = imread(vessel_image);
                if(size(vesselized_img, 3) > 1)
                    vesselized_img = rgb2gray(vesselized_img(:,:,1:3));
                end
                vesselized_img_binary = double(imresize(vesselized_img, [std_img_size, std_img_size]));
                vesselized_img_binary(vesselized_img_binary==0) = -1;

                %Get the original image
                original_img = imread(get_pathv2(pid, eye, time, 'original'));

                %Pre-process
                if (size(original_img, 3) > 1)
                    original_img = rgb2gray(original_img(:,:,1:3));
                end
                
                %Imcomplement the file if a angiogram
                if strcmp(imcomp,'complement') == 1
                    original_img = imcomplement(original_img);
                end
                
                original_img = imresize(original_img, [768 768]);
                original_img = gaussian_filter(original_img);
                [original_img, ~] = correct_illum(original_img,0.7);
                original_img = imcomplement(original_img);
                original_img = zero_m_unit_std(original_img);
                
                if(debug == 1)
                    disp(['Extracting Info: ', pid, ' ', eye, ' (', time, ') Ref: ', vessel_image]);
                end
                
                %Run Gabor, save max at each scale, normalize via zero_m_unit_std 
                if(gabor_bool == 1)  
                    [sizey, sizex] = size(original_img);
                    bigimg = padarray(original_img, [50 50], 'symmetric');
                    fimg = fft2(bigimg);
                    k0x = 0;
                    k0y = 3;
                    epsilon = 4;
                    step = 10;
                    feature_image = [];
                    for a = [1 2 3 4 5]
                        trans = maxmorlet(fimg, a, epsilon, [k0x k0y], step);
                        trans = trans(51:(50+sizey), (51:50+sizex));
                        feature_image = cat(3, feature_image, trans);
                    end
                end
            
                if (lineop_bool == 1)                
                    %Build lineop feature vectors
                    [feature_image,~] = get_fv_lineop( original_img );
                end
                
                %Save feature vectors and pixel classes for current image in .mat file generated above
                feature_vectors = matstack2array(feature_image);
                [nrows,~] = size(file_obj, 'dataset');
                file_obj.dataset(nrows+1:nrows+numel(original_img),1:size(feature_vectors,2)) = feature_vectors;
                file_obj.classes(nrows+1:nrows+numel(original_img),1) = vesselized_img_binary(:);
        end              
    catch err
        error(err.message);
    end
    
    e = cputime - t;
    disp(['Time to build dataset (min): ', num2str(e / 60.0)]);

end


function valid_debug(debug)
    try
        debug_num = num2str(debug);
        if(debug_num ~= 0 && debug_num ~= 1 && debug_num ~= 2)
            error('Varagin inpuit from debug is not a valid number');
        end
    catch
        error('Varargin input from debug is incorrect');
    end
end

function valid_imcomp(imcomp)
    gtg = 0;
    if(strcmp(imcomp, 'complement') == 1)
        gtg = 1;
    end
    if(strcmp(imcomp, 'none') == 1)
        gtg = 1;
    end

    if gtg == 0
        error('Varargin input for imcomp is incorrect');
    end
end
        
