function time_lapse()
    %Add the location of the get_path script
    addpath('..');
    addpath(genpath('../Test Set'));
    addpath('../roi_mask');

    %Get the images to include from this list
    fid = fopen('np_draw.training', 'r');
    includes = textscan(fid,'%q %q %d %*[^\n]');
    fclose(fid);

    %Test to make sure that all the appropiate images are available
    disp('----------Checking Files---------');
    pid = 'none';
    eye = 'none';
    time = -1;
    err_cnt = 0;
    for k=1:size(includes{1}, 1)
        try
            pid = char(includes{1}{k});
            eye = char(includes{2}{k});
            time = num2str(includes{3}(k));

            %Check to see that the path to the image is readable
            the_path = get_pathv2(pid, eye, time, 'original');
            img = imread(the_path);
        catch E
            disp(['Could not load original image: ', pid, ' Eye: ',eye, ' Time: ', time]);
            disp(E.message);
            err_cnt = err_cnt + 1;
        end
    end
    if err_cnt == 0
        disp('All Files Look Ready To Rumble');
    end
    disp('-------Done Checking Files-------');
    
    %Output results
    final_graph = zeros(size(img,1), size(img,2), size(includes{1},1));
    
    registered_images = zeros(
    
    %Iterate over the files
    for k=1:size(includes{1}, 1)
        try
            pid = char(includes{1}{k});
            eye = char(includes{2}{k});
            time = num2str(includes{3}(k));

            %Check to see that the path to the image is readable
            the_path = get_pathv2(pid, eye, time, 'original');
            img = imread(the_path);
            
            %Find the roi and return a mask
            roi_mask = find_roi(img);
            
            %Get the intensities over time
            for y=1:size(img,1)
                for x=1:size(img,2)
                    if(roi_mask(y,x) == 1)
                        final_graph(y,x,k) = img(y,x);
                    end
                end
            end
        catch E
            reportErro(E);
        end
    end
end