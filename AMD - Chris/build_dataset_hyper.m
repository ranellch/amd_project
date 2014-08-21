function build_dataset_hyper()
%Constants for file names
mat_file = 'hyper_training_data.mat';

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
addpath('../superpixels');

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
fid = fopen('hyper_draw.training', 'r');
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
        
        %Get the labeled images
        labeled_img = imread(get_pathv2(pid, eye, time, 'AMD'));
        hyper_img = labeled_img(:,:,1) > labeled_img(:,:,2);
        hypo_img = labeled_img(:,:,2) > labeled_img(:,:,1);
        
        
        %Resize images to a standard sizing
        img = imresize(img, [std_size std_size]);
        hyper_img = imresize(hyper_img, [std_size std_size]);

        %Apply a gaussian filter to the img  and the smooth out the illumination
        img = gaussian_filter(img);
        img = correct_illum(img,0.7);
        
        %get superpixels from intensity image
        [x,y] = get_fovea(pid, eye, time);
        im = cat(3,img, img,img);
        n = 1000;
        m = 20;
        seRadius = 1;
        threshold = 4;
        [l, Am, Sp, ~] = slic(im, n, m, seRadius);
        %cluster superpixels
        lc = spdbscan(l, Sp, Am, threshold);
        %generate feature vectors for each labeled region
        [~, Al] = regionadjacency(lc);
        if any(hypo_img(:))
            hypo_input = hypo_img;
        else 
            hypo_input = [x,y];
        end
        feature_vectors = get_fv_hyper(lc,Al,hypo_input,img);
        %generate label vector
        labels = zeros(size(feature_vectors,1),1);
        for i = 1:size(feature_vectors,1)
            overlap = hyper_img & lc==i;
            if sum(overlap(:)==1)/numel(lc(lc==i)) > .9
                labels(i) = 1;
            else
                labels(i) = 0;
            end
        end
        %Save feature vectors and pixel classes for current image in .mat file generated above
        [nrows,~] = size(file_obj, 'dataset');
        file_obj.dataset(nrows+1:nrows+size(feature_vectors,1),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.classes(nrows+1:nrows+size(feature_vectors,1),1) = double(labels);
    catch e
        disp(['Could not deal with: ', pid, '(', time, ')']);
        disp(getReport(e));
    end
end

e = cputime - t;
disp(['Hyper Build Classifier Time (min): ', num2str(e/60.0)]);
end
