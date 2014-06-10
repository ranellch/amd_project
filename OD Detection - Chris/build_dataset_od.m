function build_dataset_od()
%constant for standard image sizes
std_img_size = 768;

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
addpath(genpath('..\Test Set'));

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
        img = match_sizing(img, std_img_size);
        snaked_image = match_sizing(snaked_image, std_img_size);

        %Apply a gaussian filter to the img  and the smooth out the illumination
        img = gaussian_filter(img);
        [img, ~] = smooth_illum3(img, 0.7);

        %Check that the images are the same size
        if(size(img,1) ~= size(snaked_image,1) || size(img,2) ~= size(snaked_image,2))
            disp('Oringal Img and Snaked Img do not have the same size');
            continue;
        end

        %Get the pixelwise feature vectors of the input image
        feature_image_g = get_fv_gabor(img);
        feature_image_r = rangefilt(img);
        
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

function other()
    number_of_pixels_per_box = 8;

    subimage_size = floor(std_img_size / number_of_pixels_per_box);
    windowed_snaked_image = zeros(subimage_size, subimage_size);

    %This is a window based feature descriptor
    for x=1:subimage_size
        for y=1:subimage_size
            xs = ((x - 1) * number_of_pixels_per_box) + 1;
            xe = xs + number_of_pixels_per_box - 1;

            ys = ((y - 1) * number_of_pixels_per_box) + 1;
            ye = ys + number_of_pixels_per_box - 1;

            if(ye > size(img, 1))
                ye = size(img, 1);
                ys = ye - number_of_pixels_per_box;
            end
            if(xe > size(img, 2))
                xe = size(img, 2);
                xs = xe - number_of_pixels_per_box;
            end

            %Get the snake image window
            subimage_snake = snaked_image(ys:ye, xs:xe);

            %Get the percentage of the disk included in this image
            percentage_disk = sum(subimage_snake(:)) / (number_of_pixels_per_box * number_of_pixels_per_box);

            %Get the grouping associated with dis badboy
            grouping = 0;
            cutoff = 0.9;
            if(percentage_disk >= cutoff)
                grouping = 1;
            end

            %Log the results for the windowed image
            windowed_snaked_image(y,x) = grouping;
        end
    end
        
    if 0
        disp('Running Texture Windowing');
        %Divide the image up into equal sized boxes
        subimage_size = std_img_size / number_of_pixels_per_box;

        %This is a window based feature descriptor
        for x=1:subimage_size
            for y=1:subimage_size              
                %Save feature vectors and pixel classes for current image in .mat file generated above
                feature_vectors = text_algorithm(subimage);
                [nrows,~] = size(file_obj, 'dataset');
                file_obj.dataset(nrows+1,1:size(feature_vectors,2)) = feature_vectors;
                file_obj.classes(nrows+1,1) = windowed_snaked_image(y,x);
            end
        end
    elseif 0
        %Get lbp results over the image
        texture_results = vl_lbp(single(img), number_of_pixels_per_box);

        %Get the HOG results over the image
        %texture_results = vl_hog(single(img), number_of_pixels_per_box, 'verbose') ;
        
        %Save feature vectors and pixel classes for current image in .mat file generated above
        feature_vectors = matstack2array(texture_results);
        [nrows,~] = size(file_obj, 'dataset');
        file_obj.dataset(nrows+1:nrows+size(feature_vectors,1),1:size(feature_vectors,2)) = feature_vectors;
        file_obj.classes(nrows+1:nrows+size(feature_vectors,1),1) = windowed_snaked_image(:);
    end
end