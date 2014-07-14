function build_dataset_vessels(varargin)
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

    %Disp to user the current operation about to be done
    disp('Building the vessel dataset')

    %Filename constants
    filename_input = 'vessel_draw.training';
    filename_data = 'vessel_data.mat';

    %Remove file is already exists
    if exist(filename_data, 'file') == 2
        delete(filename_data);
    end

    %Add paths for the running of this function
    addpath(genpath('../../Test Set'));
    addpath(genpath('../../intensity normalization'))

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
            
            image_exists = get_path_np(pid, eye, time, 'original');
            imread(image_exists);
            
            vessel_image = get_path_np(pid, eye, time, 'vessels');
            imread(vessel_image);
        end
        catch E
            error(E.message);
        end
       
        %Open the output file for writing 
        file_obj = matfile(filename_data,'Writable',true);
        file_obj.dataset = [];
        file_obj.classes = [];

        %Iterate over all images to use for training 
        for k=1:numimages
                pid = char(paths{1}{k});
                eye = char(paths{2}{k});
                time = num2str((paths{3}(k)));
                vessel_image = get_path_np(pid, eye, time, 'vessels');

                %Get the vesselized image and convert it to a binary image
                vesselized_img = imread(vessel_image);
                if(size(vesselized_img, 3) > 1)
                    vesselized_img = vesselized_img(:,:,1);
                end
                vesselized_img_binary = double(im2bw(imresize(vesselized_img, [std_img_size, std_img_size])));
                vesselized_img_binary(vesselized_img_binary==0) = -1;

                %Get the original image
                original_img = imread(get_path_np(pid, eye, time, 'original'));

                %Pre-process
                if (size(original_img, 3) > 1)
                    original_img = rgb2gray(original_img(:,:,1:3));
                end
                
                %Imcomplement the file if a angiogram
                if strcmp(imcomp,'complement') == 1
                    original_img = imcomplement(original_img);
                end
                
                original_img = imresize(original_img, [std_img_size std_img_size]);
                original_img = gaussian_filter(original_img);
                [original_img, ~] = correct_illum(original_img,0.7);
                original_img = imcomplement(original_img);
                original_img = zero_m_unit_std(original_img);
                
                if(debug == 1)
                    disp(['Extracting Info: ', pid, ' ', eye, ' (', time, ') Ref: ', vessel_image]);
                end
                
                %Build lineop feature vectors
                [lineop_image,~] = get_fv_lineop( original_img );
                
                %Run Gabor, save max at each scale, normalize via zero_m_unit_std  
                gabor_image = get_fv_gabor(original_img);
                
                %Build feature image
                feature_image = cat(3,lineop_image, gabor_image);          
                
                %Save feature vectors and pixel classes for current image in .mat file generated above
                feature_vectors = matstack2array(feature_image);
                [nrows,~] = size(file_obj, 'dataset');
                file_obj.dataset(nrows+1:nrows+numel(original_img),1:size(feature_vectors,2)) = feature_vectors;
                file_obj.classes(nrows+1:nrows+numel(original_img),1) = vesselized_img_binary(:);
        end              
    catch err
        disp(err.stack);
        error(err.message);
    end
    
    e = cputime - t;
    disp(['Time to build dataset (min): ', num2str(e / 60.0)]);

end


function valid_debug(debug)
    try
        debug_isnum = num2str(debug);

        if(debug ~= 0 && debug ~= 1 && debug ~= 2)
            error('Varagin input from debug is not a valid number');
        end
    catch err
        error(err.message);
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
        
