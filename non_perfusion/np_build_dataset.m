function np_build_dataset(varargin)
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
    
    %Path constants
    addpath('illum');
    addpath('xmlfunc');
    addpath('auxfunc');
    
    %Remove file is already exists
    filename_data = 'np_data.mat';
    if exist(filename_data, 'file') == 2
        delete(filename_data);
    end
    
    t = cputime;
    
    try
        %Open the file to determine which images to use for training
        fid = fopen('np.training', 'r');
        lines = textscan(fid,'%q %q %q %*[^\n]');
        fclose(fid);
        
        numimages = size(lines{1}, 1);
        
        %Make sure that all images and paths exist
        addpath(genpath(images_path));
        disp('----Checking Files----');
        for k=1:numimages
            pid = char(lines{1}{k});
            eye = char(lines{2}{k});
            time = char(lines{3}(k));
            
            [video_xml, directory] = get_video_xml(pid, eye, time, 'seq_path');
            
            disp([pid, ' - ', eye, ' - ', time]);
        end
        disp('-----Done Checking Files-----');
        
        %Open and create the file to hold the video sets written to mat files
        names_matrix = [];
        
        %Iterate over all images to use for training 
        for i=1:numimages            
            pid = char(lines{1}{i});
            eye = char(lines{2}{i});
            time = char(lines{3}(i));
            
            %Display to the user the current video going to be analyzed
            disp(['[PID] ', pid, ' [Eye] ', eye, ' [Time] ', time]);
            
            disp('------Feature Extraction-----');
            try
                %Run the feature extraction on each image
                [data_matrix, timing_matrix, binary_matrix, names_matrix_line] = get_image_features(pid, eye, time, std_img_size, 1);
                
                %Delete the names of the matricies to be saved
                for j=1:size(names_matrix_line,1)
                    if exist(strtrim(names_matrix_line{j}), 'file') == 2
                        delete(strtrim(names_matrix_line{j}));
                    end
                end
                
                %Save the datafile
                save(strtrim(names_matrix_line{1}), 'data_matrix');
                save(strtrim(names_matrix_line{2}), 'timing_matrix');
                save(strtrim(names_matrix_line{3}), 'binary_matrix');
            
                %Log this list of files names
                names_matrix = [names_matrix names_matrix_line];
            catch e
                for i=1:size(e.stack, 1)
                    disp(e.stack(i));
                end
                error(e.message);n
            end
            disp('------End Feature Extraction-----');
        end
        
        %Save the list of names that were condensed into a list
        save(filename_data, 'names_matrix');
        
        e = cputime - t;
        disp(['Time to build dataset (min): ', num2str(e / 60.0)]);
    catch Ex
        disp('-----Stack Errors-----');
        for i=1:length(Ex.stack)
            disp(Ex.stack(i));
        end
        error(Ex.message);
    end
end
