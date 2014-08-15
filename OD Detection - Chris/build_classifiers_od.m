function build_classifiers_od()

std_img_size = 768;

%Constants for file names
od_file = 'od_training_data.mat';

%Get the time of the start of this function to get how long it took to run.
t = cputime;

%Check if training file already exists
if(exist(od_file, 'file') == 2)
    button = questdlg('Training dataset aready exists.  Overwrite?');
    if strcmp(button,'Yes')
        delete(od_file);
    else
        disp('Please move file to new directory for safekeeping')
        return
    end
end
file_obj = matfile(od_file,'Writable',true);
file_obj.pixel_features = [];
file_obj.region_features = [];

%Add the location of the get_path script
addpath('..');

%Add the location of the images resultant from get_path
if ispc
addpath(genpath('..\Test Set'));
addpath(genpath('..\Vessel Detection - Chris'));
addpath(genpath('..\intensity normalization'));
addpath(genpath('..\libsvm-3.18'));
else
addpath(genpath('../Test Set'));
addpath(genpath('../Vessel Detection - Chris'));
addpath(genpath('../intensity normalization'));
addpath(genpath('../libsvm-3.18'));
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
            od_path = get_pathv2(pid, eye, time, 'optic_disc');
            od_img = imread(od_path);
        catch
            disp(['Could not load od image: ', pid , ' - ', time]);
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


%Time to start iterating over all the images in the file
disp('Building pixel dataset')
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
        
        %Crop footer if need be
        img = crop_footer(img);
        
        %Get the snaked image
        od_img = imread(get_pathv2(pid, eye, time, 'optic_disc'));
        if size(od_img,3) > 1
            od_img = od_img(:,:,1);
        end        
        
        %Resize images to a standard sizing
        img = imresize(img, [std_img_size std_img_size]);
        od_img = imresize(od_img, [std_img_size std_img_size]);

        %Apply a gaussian filter to the img  and the smooth out the illumination
        img = gaussian_filter(img);
        img = correct_illum(img,0.7);
        
%-----------Build Classifier 1--------------------------------------

        %Get the pixelwise feature vectors of the input image
        feature_image_g = get_fv_gabor_od(img);
        feature_image_r = imfilter(img,ones(3)/9, 'symmetric');
        
        feature_image = zeros(size(img,1), size(img,2), size(feature_image_g,3) + size(feature_image_r, 3));
        
        for y=1:size(feature_image, 1)
            for x=1:size(feature_image,2)
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
        [nrows,~] = size(file_obj, 'pixel_features');
        file_obj.pixel_features(nrows+1:nrows+numel(img),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.pixel_classes(nrows+1:nrows+numel(img),1) = od_img(:);
               
    catch e
        disp(['Could not deal with: ', pid, '(', time, ')']);
        disp(getReport(e));
    end
end

%--------------Train classifier 1-------------
train_od('pixel');

%--------------Build Classifier 2--------------------
e = cputime - t;
disp(['Total Optic Disc Build Pixel Classifier Time (min): ', num2str(e/60.0)]);

t = cputime;

%Build texture region classifier
disp('Building region dataset')
model = load('od_classifiers.mat', 'scaling_factors','pixel_classifier');
scaling_factors = model.scaling_factors;
classifier = model.pixel_classifier;

for k=1:size(includes{1}, 1)
    %Get the patient_id and time of the image to run
    pid = char(includes{1}{k});
    eye = char(includes{2}{k});
    time = num2str(includes{3}(k));
    disp(['Running: ', pid, ' - ', time]);
    
    try
        %Run texture classification on pixels/feature vectors corresponding
        %to this image
        od_texture_img = zeros(std_img_size, std_img_size);
        feature_vectors = file_obj.pixel_features((k-1)*std_img_size^2+1:k*std_img_size^2,:);
        
        %Scale the vectors for input into the pixel classifier
        for i = 1:size(feature_vectors,2)
            fmin = scaling_factors(1,i);
            fmax = scaling_factors(2,i);
            feature_vectors(:,i) = (feature_vectors(:,i)-fmin)/(fmax-fmin);
        end
        
        %Get texture segmented image
        od_texture_img(:) = libpredict(zeros(length(feature_vectors),1), sparse(feature_vectors), classifier, '-q');

        [feature_vectors,classes] = get_fv_od_regions(od_img, od_texture_img,pid,eye,time);
        if isempty(classes)
            continue
        end

        %Save region feature vectors
        [nrows,~] = size(file_obj, 'region_features');
        file_obj.region_features(nrows+1:nrows+size(feature_vectors,1),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.region_classes(nrows+1:nrows+size(feature_vectors,1),1) = classes;      
                       
    catch e
        disp(['Could not deal with: ', pid, '(', time, ')']);
        disp(getReport(e));
    end
end

%--------------Train classifier 2-------------
train_od('region');


e = cputime - t;
disp(['Total Optic Disc Build Region Classifier Time (min): ', num2str(e/60.0)]);

end
