function build_np_dataset(varargin)
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
        valid_debug(debug);
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
    end
    
    %constant for standard image sizes
    std_img_size = 768;

    disp('Building the non_perfusion dataset');
    
    %Filename constants
    filename_input = 'np.training';
    filename_data = 'np_data.mat';
    images_path = '../Test Set/';
    addpath('illum');
    
    %Remove file is already exists
    if exist(filename_data, 'file') == 2
        delete(filename_data);
    end
    
    t = cputime;
    
    try
        %Open the file to determine which images to use for training 
        fid = fopen(filename_input, 'r');
        paths = textscan(fid,'%q %q %q %*[^\n]');
        fclose(fid);
        
        numimages = size(paths{1}, 1);
        
        %Make sure that all images and paths exist
        addpath(genpath(images_path));
        disp('----Checking Files----');
        for k=1:numimages
            pid = char(paths{1}{k});
            eye = char(paths{2}{k});
            time = char(paths{3}(k));
            
            labeled_path = get_image_xml(pid, eye, time, 'path');
            original_path = get_image_xml(pid, eye, time, 'original');
            imgl = imread(labeled_path);
            imgo = imread(original_path);
                
            disp([pid, ' - ', time, ' - ', time]);
        end
        disp('-----Done Checking Files-----');
        
        %Open the output file for writing 
        file_obj = matfile(filename_data,'Writable',true);
        file_obj.dataset = [];
        file_obj.classes = [];
        
        %Iterate over all images to use for training 
        for i=1:numimages
            pid = char(paths{1}{i});
            eye = char(paths{2}{i});
            time = char(paths{3}(i));
            
            disp(['[PID] ', pid, ' [Eye] ', eye, ' [Time] ', time]);
            
            %Get the labeled image and process it
            labeled_path = get_image_xml(pid, eye, time, 'path');
            labeled_image = imread(labeled_path);
            labeled_image = process_labeled(labeled_image);
            labeled_image = imresize(labeled_image, [std_img_size, NaN]);

            %Get the original image
            original_path = get_image_xml(pid, eye, time, 'original');
            original_image = imread(original_path);

            %Convert the image to a grayscale image
            if (size(original_image, 3) > 1)
                original_image = original_image(:,:,1:3);
                original_image = rgb2gray(original_image);
            end

            %Resize the image and convert to dobule for gaussian filtering and then normalized
            original_image = imresize(original_image, [std_img_size, NaN]);
            original_image = im2double(original_image);
            original_image = gaussian_filter(original_image);
            original_image = zero_m_unit_std(original_image);
                
            %Calculate the image feature vectors
            feature_image = image_feature(original_image);

            %Save this data to the results datatable.
            feature_vectors = matstack2array(feature_image);
            [nrows,~] = size(file_obj, 'dataset');
            file_obj.dataset(nrows+1:nrows+numel(original_image),1:size(feature_vectors,2)) = feature_vectors;
            file_obj.classes(nrows+1:nrows+numel(original_image),1) = labeled_image(:);
        end
        
        e = cputime - t;
        disp(['Time to build dataset (min): ', num2str(e / 60.0)]);
    catch Ex
        for i=1:length(Ex.stack)
            disp(Ex.stack(i));
        end
        error(Ex.message);
    end
end