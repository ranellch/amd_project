function build_dataset_np()
    %Constants for file names
    np_file = 'np_training_data.mat';

    %Get the time of the start of this function to get how long it took to run.
    t = cputime;

    %Remove texture file if already exists
    if(exist(np_file, 'file') == 2)
        delete(np_file);
    end
    file_obj = matfile(np_file,'Writable',true);
    file_obj.dataset = [];

    %Add the location of the get_path script
    addpath('..');

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

            try
                %Check to make sure that the snaked image is readable
                labeled_path = get_pathv2(pid, eye, time, 'optic_disc');
                labeled_image = im2bw(imread(labeled_path));
            catch
                disp(['Could not load snaked image: ', pid , ' - ', time]);
                err_cnt = err_cnt + 1;
            end
        catch
            disp(['Could not load original image: ', pid , ' - ', time]);
            err_cnt = err_cnt + 1;
        end
    end
    if err_cnt == 0
        disp('All Files Look Ready To Rumble');
    end
    disp('-------Done Checking Files-------');
end