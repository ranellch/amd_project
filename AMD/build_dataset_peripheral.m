function build_dataset_peripheral()
%Constants for file names
mat_file = 'peripheral_training_data.mat';

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
addpath('..\Fovea Detection - Chris');
else
addpath(genpath('../Test Set'));
addpath(genpath('../Vessel Detection - Chris'));
addpath(genpath('../OD Detection - Chris'));
addpath(genpath('../intensity normalization'));
addpath('../Fovea Detection - Chris');
end

%Get the images to include from this list
fid = fopen('normal_draw.training', 'r');
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
else
    return
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
        green_line = labeled_img(:,:,2) > labeled_img(:,:,1);
        if ~any(green_line(:))
            abnormal = labeled_img(:,:,1) ~= labeled_img(:,:,3);
        else 
            abnormal = imfill(green_line,'holes');
        end
        normal_img = ~abnormal;
        
        %Resize images to a standard sizing
        img = imresize(img, [std_size std_size]);
        normal_img = imresize(normal_img, [std_size std_size]);

        %Apply a gaussian filter to the img  and the smooth out the illumination
        img = gaussian_filter(img);
        img = correct_illum(img,0.7);
        
        %Get the pixelwise feature vectors of the input image
        feature_image_g = get_fv_gabor_od(img);
        feature_image_i = imfilter(img,ones(3)/9, 'symmetric');
        feature_image = cat(3,feature_image_g, feature_image_i);
        
        %Create mask to exclude vessels and optic disk from training data
        od = imread(get_pathv2(pid, eye, time, 'optic_disc'));
        if(size(od, 3) > 1)
        	od = od(:,:,1);
        end
        od = imresize(od,[std_size,std_size]);
        od = im2bw(od);
        
        vessels = imread(get_pathv2(pid, eye, time, 'vessels'));
        if(size(vessels, 3) > 1)
        	vessels = vessels(:,:,1);
        end
        vessels = imresize(vessels,[std_size,std_size]);
        vessels = im2bw(vessels);
        
        anatomy_mask = od | vessels;
        
        %Save feature vectors and pixel classes for current image in .mat file generated above
        feature_vectors = [];
        for i = 1:size(feature_image,3)
            layer = feature_image(:,:,i);
            feature = layer(~anatomy_mask);
            feature_vectors = [feature_vectors, feature];
        end
        [nrows,~] = size(file_obj, 'dataset');
        file_obj.dataset(nrows+1:nrows+size(feature_vectors,1),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.classes(nrows+1:nrows+size(feature_vectors,1),1) = double(normal_img(~anatomy_mask));
    catch e
        disp(['Could not deal with: ', pid, '(', time, ')']);
        disp(getReport(e));
    end
end

e = cputime - t;
disp(['Normal Build Dataset Time (min): ', num2str(e/60.0)]);
end
