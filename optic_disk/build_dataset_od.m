function build_dataset_od()
%constant for standard image sizes
std_img_size = 768;
number_of_pixels_per_box = 8;

%Constants for the output file name
filename_text = 'od_texture.classifier';

%Get the time of the start of this function to get how long it took to run.
t = cputime;

%Remove texture file if already exists
if(exist(filename_text, 'file') == 2)
    delete(filename_text);
end
    
%Add texture algorithm path
addpath('sfta');

%Add the location of the get_path script
addpath('..');

%Add the location of the images resultant from get_path
addpath('../Test Set');

%Get the images to include from this list
fid = fopen('include.dataset', 'r');
includes = textscan(fid,'%q %d %*[^\n]');
fclose(fid);

%Test to make sure that all the appropiate images are available
disp('----------Checking Files---------');
pid = 'none';
time = 'none';
for x=1:size(includes{1}, 1)
    try
        pid = char(includes{1}{x});
        time = num2str(includes{2}(x));

        %Check to see that the path to the image is readable
        the_path = get_path(pid, time);
        img = imread(the_path);

        %Check to make sure that the snaked image is readable
        snaked_image = im2bw(get_snaked_img(the_path));
    catch
        disp(['Could not load image: ', pid , ' - ', time]);
    end
end
disp('-------Done Checking Files-------');

for x=1:size(includes{1}, 1)
    %Get the patient_id and time of the image to run
    pid = char(includes{1}{x});
    time = num2str(includes{2}(x));
    disp(['Running: ', pid, ' - ', time]);
    
    try
        
    %Get the path and load the image
    the_path = get_path(pid, time);
    img = imread(the_path);
    img = im2double(img);
    
    if(size(img, 3) > 1)
        img = rgb2gray(img);
    end
    
    %Apply a gaussian filter to the img
    img = gaussian_filter(img);
            
    %Calculate the size of the box that grids the image
    subimage_size = floor(size(img, 1) / number_of_pixels_per_box);
    
    %Get the snaked image
    snaked_image = im2bw(get_snaked_img(the_path));
    
    %Check that the images are the same size
    if(size(img,1) ~= size(snaked_image,1) || size(img,2) ~= size(snaked_image,2))
        disp('Oringal Img and Snaked Img do not have the same size');
        continue;
    end
    
    %Resize image to a standard sizing
    img = match_sizing(img, std_img_size, std_img_size);
    snaked_image = match_sizing(snaked_image, std_img_size, std_img_size);
    
    %open the files to write
    fileID = fopen(filename_text,'at');
        
    if(1)
    %This is a pixel based classification
    orig_wavelets = apply_gabor_wavelet(img, 0);
    random_sample = 1;
    border_ignore = 5;
	grouping_one = 0;
    grouping_zero = 0;
    
    for y=1:size(img,1)
        for x=1:size(img,2)
            %Get the gabor wavelet feature vector
            feature_vector_gabor = zeros(size(orig_wavelets, 3), 1);
            for wave=1:size(orig_wavelets, 3)
            	feature_vector_gabor(wave, 1) = orig_wavelets(y,x,wave);
            end
            
            %Get the grouping for this particular pixel
            grouping = 0;
            if(snaked_image(y,x) == 1)
                grouping = 1;
            end
            
            %Ignore the border and then either grouping is one or is some proportion 
            if(x > border_ignore && x < (size(img,2) - border_ignore) && ...
               y > border_ignore && y < (size(img,1) - border_ignore) && ...
               (grouping == 1 || random_sample >= 6))
                %Write to the output file the gabor wavelet string
                feature_string_gabor = feature_to_string(feature_vector_gabor);
                fprintf(fileID, '%d,%s\n', grouping, feature_string_gabor);

                random_sample = 1;
                if(grouping == 1)
                    grouping_one=grouping_one+1;
                else
                    grouping_zero=grouping_zero+1;
                end
            else
                random_sample = random_sample + 1;
            end
        end
    end
    else
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

            %Get the original image window
            subimage = img(ys:ye, xs:xe);
            
            %Get the snake image window
            subimage_snake = snaked_image(ys:ye, xs:xe);

            %Get the percentage of the disk included in this image
            percentage_disk = sum(subimage_snake(:)) / (number_of_pixels_per_box * number_of_pixels_per_box);

            %Get the grouping associated with dis badboy
            grouping = -1;
            if(percentage_disk > 0.9)
                grouping = 1;
            elseif(percentage_disk <.01)
                grouping = 0;
            end

            if(grouping >= 0)
                %Calculate the texture string
                texture_vector = text_algorithm(subimage);
                texture_string = feature_to_string(texture_vector);

                %Write to the output file the texture feature vector
                fprintf(fileID, '%d,%s\n', grouping, texture_string);
            end
        end
    end
    end
    catch
        disp(['Could not deal with: ', pid, '(', time, ')']);
    end
    fclose(fileID);
end

e = cputime - t;
disp(['Optic Disc Classifier Time (sec): ', num2str(e)]);
