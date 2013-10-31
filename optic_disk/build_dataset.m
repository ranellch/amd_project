function build_dataset(number_of_pixels_per_box)
%
filename_text = 'train_text.classifier';
filename_intenstiy = 'train_intensity.classifier';

%Add the location of the XML file with patient information
addpath('..');

%Add the location of the images
addpath(genpath('../Test Set'));
addpath('sfta');
addpath('lbp');
addpath('hog');

%Get the images already run in the 
mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');
try
    %Make sure that the file exists
    fidintensity = fopen(filename_intenstiy);
    fclose(fidintensity);
    
    %Open the file 
    fid = fopen(filename_text, 'r');
    paths = textscan(fid,'%q %d %*[^\n]');
    fclose(fid);
    
    for x=1:size(paths{1}, 1)
        mapObj(char(paths{1}{x})) = paths{2}(x);
    end
catch
    error('Error in opening and reading the file!');
end

%Get the images to exclude from this list
mapObjExclude = containers.Map('KeyType', 'char', 'ValueType', 'int32');
fid = fopen('exclude.dataset');
excludes = textscan(fid,'%q %*[^\n]');
fclose(fid);
for x=1:size(excludes{1}, 1)
    mapObjExclude(char(excludes{1}{x})) = 0;
end

%Get the xml document for the databsae
xDoc= xmlread('images.xml');
images = xDoc.getElementsByTagName('image');

%Loop on the image field in the images tag
for count=1:images.getLength
    image = images.item(count - 1);
    
    %Get the path and load the image
    the_path = char(image.getAttribute('path'));
    img = (imread(the_path));
    
    if(size(img, 3) > 1)
        img = rgb2gray(img);
    end
        
    %Calculate the size of the box that grids the image
    subimage_size = floor(size(img, 1) / number_of_pixels_per_box);
    
    %Should we skip this image
    if isKey(mapObjExclude, the_path)
        disp(['Skipping: ', the_path]);
        continue;
    else
        disp(['Loading: ', the_path, ' - Box Count: ', num2str(subimage_size)]);
    end
    
    %Does key exist in the map
    if isKey(mapObj, the_path) == 0
        mapObj(the_path) = 0.0;
    end
        
    %Get the snaked image
    snaked_image = im2bw(get_snaked_img(the_path));
        
    %open the files to write
    fileID = fopen(filename_text,'at');
    fidintensity = fopen(filename_intenstiy, 'at');
    
    subimages_count = 1;
    
    for x=1:subimage_size
        for y=1:subimage_size
            if mapObj(the_path) < subimages_count
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
                                
                %Get the original image square
                subimage = img(ys:ye, xs:xe);

                %Get the snake image square
                subimage_snake = snaked_image(ys:ye, xs:xe);

                %Get the percentage of the disk included in this image
                percentage_disk = sum(subimage_snake(:)) / (number_of_pixels_per_box * number_of_pixels_per_box);

                %Get the grouping associated with dis badboy
                grouping = 0;
                if(percentage_disk > 0.9)
                    grouping = 1;
                elseif(percentage_disk <.01)
                    grouping = 0;
                end
                
                %Calculate the texture string
                texture_vector = text_algorithm(subimage);
                texture_string = feature_to_string(texture_vector);
                
                %Write to the output file the texture feature vector
                fprintf(fileID, '"%s" %d, %d, %s\n', the_path, subimages_count, grouping, texture_string);

                %Calculate the intensity with mean and variance
                [mean_val, var_val] = avg_intensity(subimage);

                %Write to the output file the intensity feature vecotr
                fprintf(fidintensity, '"%s" %d, %d, %f,%f\n', the_path, subimages_count, grouping, mean_val, var_val);

                mapObj(the_path) = subimages_count;
            end
            subimages_count = subimages_count + 1;
        end
    end
    
    fclose(fidintensity);
    fclose(fileID);
end
