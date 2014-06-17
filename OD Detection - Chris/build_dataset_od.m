function build_dataset_od()
%Constants for file names
od_file = 'od_classify.mat';

%Get the time of the start of this function to get how long it took to run.
t = cputime;

%Remove texture file if already exists
if(exist(od_file, 'file') == 2)
    delete(od_file);
end
file_obj = matfile(od_file,'Writable',true);
file_obj.dataset = [];

%Add the location of the get_path script
addpath('..');

%Add the location of the images resultant from get_path
if ispc
addpath(genpath('..\Test Set'));
addpath(genpath('..\Vessel Detection - Chris'));
addpath(genpath('..\intensity normalization'));
else
addpath(genpath('../Test Set'));
addpath(genpath('../Vessel Detection - Chris'));
addpath(genpath('../intensity normalization'));
end

%Get the images to include from this list
fid = fopen('od_draw.training', 'r');
includes = textscan(fid,'%q %q %d %*[^\n]');
fclose(fid);

%Test to make sure that all the appropiate images are available
disp('----------Checking Files---------');
pid = 'none';
eye = 'none';
time = -1;
err_cnt = 0;
for x=1:size(includes{1}, 1)
    try
        pid = char(includes{1}{x});
        eye = char(includes{2}{x});
        time = num2str(includes{3}(x));
      
        %Check to see that the path to the image is readable
        the_path = get_pathv2(pid, eye, time, 'original');
        img = imread(the_path);
        
        try
            %Check to make sure that the snaked image is readable
            snaked_path = get_pathv2(pid, eye, time, 'optic_disc');
            snaked_image = im2bw(imread(snaked_path));
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


%Time to start iterating over all the images in the 
for x=1:size(includes{1}, 1)
    %Get the patient_id and time of the image to run
    pid = char(includes{1}{x});
    eye = char(includes{2}{x});
    time = num2str(includes{3}(x));
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
        
        %Get the snaked image
        snaked_image = im2bw(imread(get_pathv2(pid, eye, time, 'optic_disc')));
        
        %Resize images to a standard sizing
        img = imresize(img, [768 768]);
        snaked_image = imresize(snaked_image, [768 768]);

        %Apply a gaussian filter to the img  and the smooth out the illumination
        img = gaussian_filter(img);
        img = correct_illum(img,0.7);
        norm_img = zero_m_unit_std(img);
        
        %Get the pixelwise feature vectors of the input image
        feature_image_g = get_fv_gabor_od(norm_img);
        feature_image_r = imfilter(norm_img,ones(3)/9, 'symmetric');
        
        feature_image = zeros(size(img,1), size(img,2), size(feature_image_g,3) + size(feature_image_r, 3));
        
        for y=1:size(feature_image, 1)
            for x=1:size(feature_image, 2)
                temp = 1;
                for z1=1:size(feature_image_g,3)
                    feature_image(y,x,temp) = feature_image_g(y,x,z1);
                    temp = temp + 1;
                end
                for z2=1:size(feature_image_r,3)
                    feature_image(y,x,temp) = feature_image_r(y,x,z2);
                    temp = temp + 1;
                end
            end
        end
        
        %Save feature vectors and pixel classes for current image in .mat file generated above
        feature_vectors = matstack2array(feature_image);
        [nrows,~] = size(file_obj, 'dataset');
        file_obj.dataset(nrows+1:nrows+numel(img),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.classes(nrows+1:nrows+numel(img),1) = snaked_image(:);
    catch e
        disp(['Could not deal with: ', pid, '(', time, ')']);
        disp(getReport(e));
    end
end

e = cputime - t;
disp(['Optic Disc Build Classifier Time (min): ', num2str(e/60.0)]);
end
