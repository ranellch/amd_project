function build_dataset_hypo()
%Constants for file names
mat_file = 'hypo_training_data.mat';

%Get the time of the start of this function to get how long it took to run.
t = cputime;
std_size = 768;

%Remove texture file if already exists
if(exist(mat_file, 'file') == 2)
    delete(mat_file);
end
file_obj = matfile(mat_file,'Writable',true);
file_obj.dataset = [];
file_obj.classes = [];

%Add the location of the get_path script
addpath('..');

%Add the location of the images resultant from get_path
if ispc
addpath(genpath('..\Test Set'));
addpath(genpath('..\Vessel Detection - Chris'));
addpath(genpath('..\OD Detection - Chris'));
addpath(genpath('..\intensity normalization'));
else
addpath(genpath('../Test Set'));
addpath(genpath('../Vessel Detection - Chris'));
addpath(genpath('../OD Detection - Chris'));
addpath(genpath('../intensity normalization'));
end

%Get the images to include from this list
fid = fopen('hypo_draw.training', 'r');
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
            %Check to make sure that the labeled images are readable
            amd_path = get_pathv2(pid, eye, time, 'AMD');
            img =  imread(amd_path);
        catch
            disp(['Could not load AMD image: ', pid , ' - ', time]);
            err_cnt = err_cnt + 1;
        end
        try
            %Check to make sure that the labeled images are readable
            vessel_path = get_pathv2(pid, eye, time, 'vessels');
            img =  imread(vessel_path);
        catch
            disp(['Could not load vessel image: ', pid , ' - ', time]);
            err_cnt = err_cnt + 1;
        end
        try
            %Check to make sure that the labeled images are readable
            od_path = get_pathv2(pid, eye, time, 'optic_disc');
            img =  imread(od_path);
        catch
            disp(['Could not load optic disk image: ', pid , ' - ', time]);
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


%Time to start iterating over all the images in the 
for k=1:size(includes{1}, 1)
    %Get the patient_id and time of the image to run
    pid = char(includes{1}{k});
    eye = char(includes{2}{k});
    time = num2str(includes{3}(k));
    disp(['Running: ', pid, ' - ', time]);
    
    try
        %Get the path and load the image
        the_path = get_pathv2(pid, eye, time, 'original');
        img = imread(the_path);
        img = im2double(img);

        %Convert the image to a grayscale image if need be
        if(size(img, 3) > 1)
            img = rgb2gray(img);
        end
        
        %Get the labeled image
        labeled_img = imread(get_pathv2(pid, eye, time, 'AMD'));
        labeled_img = labeled_img(:,:,3) > labeled_img(:,:,1);
        
        %Resize images to a standard sizing
        img = imresize(img, [std_size std_size]);
        labeled_img = imresize(labeled_img, [std_size std_size]);

        %Apply a gaussian filter to the img  and the smooth out the illumination
        img = gaussian_filter(img);
        img = correct_illum(img,0.7);
        norm_img = zero_m_unit_std(img);
        
        %Get the pixelwise feature vectors of the input image
        feature_image_g = get_fv_gabor_od(norm_img);
        [x,y] = get_fovea(pid, eye, time);
        feature_image_i = imfilter(norm_img,ones(3)/9, 'symmetric');
        feature_image_r = get_radial_coords(size(norm_img),x,y);
        
        feature_image = cat(3,feature_image_g,feature_image_i,feature_image_r);
        
        %Create mask to exclude vessels and optic disk from training data
        od = im2bw(imread(get_pathv2(pid, eye, time, 'optic_disc')));
        vessels = im2bw(imread(get_pathv2(pid, eye, time, 'vessels')));
        
        anatomy_mask = od || vessels;
        
        %Save feature vectors and pixel classes for current image in .mat file generated above
        feature_vectors = [];
        for i = 1:std_size
            for j = 1:std_size
                if anatomy_mask(j,i) ~= 1
                    current_vector = feature_image(j,i,:);
                    feature_vectors = [feature_vectors; current_vector];
                end
            end
        end
        [nrows,~] = size(file_obj, 'dataset');
        file_obj.dataset(nrows+1:nrows+numel(img),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.classes(nrows+1:nrows+numel(img),1) = labeled_img(~anatomy_mask);
    catch e
        disp(['Could not deal with: ', pid, '(', time, ')']);
        disp(getReport(e));
    end
end

e = cputime - t;
disp(['Optic Disc Build Classifier Time (min): ', num2str(e/60.0)]);
end
