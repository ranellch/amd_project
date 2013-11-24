function build_dataset_od(number_of_pixels_per_box)
%constant for standard image sizes
std_img_size = 768;
    
    
filename_text = 'train_text.classifier';
filename_intenstiy = 'train_intensity.classifier';

t = cputime;

%Remove texture file is already exists
if(exist(filename_text, 'file') == 2)
    delete(filename_text);
end
    
%Remove intensity file is already exists
if(exist(filename_intenstiy, 'file') == 2)
    delete(filename_intenstiy);
end

%Add the location of the get_path script
addpath('..');

%Add the location of the images
addpath('../Test Set');

%Get the images to exclude from this list
fid = fopen('include.dataset');
includes = textscan(fid,'%q %d %*[^\n]');
fclose(fid);

%Test to make sure that all the appropiate images are available
for x=1:size(includes{1}, 1)
    pid = char(includes{1}{x});
    time = num2str(includes{2}(x));
    
    %disp([pid, ' ', time]);
    
    %Check to see that the path to the image is readable
    %the_path = get_path(pid, time);
    %img = imread(the_path);
    
    %Check to make sure that the snaked image is readable
    %snaked_image = im2bw(get_snaked_img(the_path));
end

for x=1:size(includes{1}, 1)
    %Get the patient_id and time of the image to run
    pid = char(includes{1}{x});
    time = num2str(includes{2}(x));
    disp(['Running: ', pid, ' - ', time]);
    
    %Get the path and load the image
    the_path = get_path(pid, time);
    img = imread(the_path);
    
    if(size(img, 3) > 1)
        img = rgb2gray(img);
    end
    
    %Apply a gaussian filter to the img
    img = gaussian_filter(img);
    
    %Resize image to a square
    img = match_sizing(img, std_img_size, std_img_size);
        
    %Calculate the size of the box that grids the image
    subimage_size = floor(size(img, 1) / number_of_pixels_per_box);
    
    %Get the snaked image
    snaked_image = im2bw(get_snaked_img(the_path));
        
    %open the files to write
    fileID = fopen(filename_text,'at');
    fidintensity = fopen(filename_intenstiy, 'at');
    
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

                %Calculate the intensity with mean and variance
                [mean_val, var_val] = avg_intensity(subimage);

                %Write to the output file the intensity feature vecotr
                fprintf(fidintensity, '%d,%f,%f\n', grouping, mean_val, var_val);
            end
        end
    end
    
    fclose(fidintensity);
    fclose(fileID);
    
    e = cputime - t;
    disp(['Optic Disc Classifier Time (sec): ', num2str(e)]);
end
