function [out] = build_dataset()
%Add the location of the XML file with patient information
addpath('..');

number_of_pixels_per_box = 32;

out = 'done';

%Add the location of the images
addpath(genpath('../Test Set'));
addpath('sfta');

%Get the images lready run
mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');
fid = fopen('train.dataset');
paths = textscan(fid,'%q %d %*[^\n]');
fclose(fid);

for x=1:size(paths{1}, 1)
    mapObj(char(paths{1}{x})) = paths{2}(x);
end

%Get the images to exclude
mapObjExclude = containers.Map('KeyType', 'char', 'ValueType', 'int32');
fid = fopen('exclude.dataset');
excludes = textscan(fid,'%q %*[^\n]');
fclose(fid);

for x=1:size(excludes{1}, 1)
    mapObjExclude(char(excludes{1}{x})) = 0;
end

%Start iterating through all the images to run
xDoc= xmlread('images.xml');
images = xDoc.getElementsByTagName('image');

%Loop on the image field in the images tag
for count=1:images.getLength
    image = images.item(count - 1);
    
    %Get the path and load the image
    the_path = char(image.getAttribute('path'));
    image = imread(the_path);
    
    %Calculate the size of the 
    subimage_size = floor(size(image, 1) / number_of_pixels_per_box);
    
    if isKey(mapObjExclude, the_path)
        disp(['Skipping: ', the_path]);
        continue;
    else
        disp(['Loading: ', the_path, ' - Box Count: ', num2str(subimage_size)]);
    end

    if isKey(mapObj, the_path) == 0
        mapObj(the_path) = 0.0;
    end
    
    last_part_in_path = strfind(the_path, '/');
    last_index = 1;
    if ~isempty(last_part_in_path)
        last_index = last_part_in_path(length(last_part_in_path));
    end
    
    %Get the snaked file
    snaked_file_name = ['snaked/', the_path(last_index:length(the_path))];
    snaked_image = im2bw(imread(snaked_file_name));
        
    fileID = fopen('train.dataset','at');
    
    subimages_count = 1;
    
    for x=1:subimage_size
        for y=1:subimage_size
            if mapObj(the_path) < subimages_count
                xs = ((x - 1) * number_of_pixels_per_box) + 1;
                xe = xs + number_of_pixels_per_box - 1;
                
                ys = ((y - 1) * number_of_pixels_per_box) + 1;
                ye = ys + number_of_pixels_per_box - 1;
                
                if(ye <= size(image, 1) && xe <= size(image, 2))              
                    %Get the original image
                    subimage = image(ys:ye, xs:xe);

                    %Get the snake image
                    subimage_snake = snaked_image(ys:ye, xs:xe);
                    
                    %Get the percentage of the disk included in this image
                    percentage_disk = sum(subimage_snake(:)) / (number_of_pixels_per_box * number_of_pixels_per_box);
                                        
                    if(percentage_disk > 0.85)
                        fprintf(fileID, '"%s" %d, 1, %s\n', the_path, subimages_count, sfta_to_string(subimage));
                    else if(percentage_disk <.01)
                        fprintf(fileID, '"%s" %d, 0, %s\n', the_path, subimages_count, sfta_to_string(subimage));
                    end
                    
                    mapObj(the_path) = subimages_count;
                end
            end
            subimages_count = subimages_count + 1;
        end
    end
    
%     if mapObj(the_path) < 11
%         figure(1);
%         imshow(image);
%         [centerx, centery] = ginput(1);
%         close 1;
%         
%         xs = centerx(1) - (minimum_size / 2);
%         if(xs <= 0)
%             xs = 1;
%         end
%         xe = xs + minimum_size;
%         
%         ys = centery(1) - (minimum_size / 2);
%         if(ys <= 0)
%             ys = 1;
%         end
%         ye = ys + minimum_size;
%         
%         optic_disk_image = image(ys:ye, xs:xe);
%         figure(3);
%         imshow(optic_disk_image);
%         yesnobutton = questdlg('Does this image contain an optic disc?','Optic Disc?','Yes','No', 'Cancel', 'Cancel');
%         switch yesnobutton
%             case 'Yes'
%                 found_optic_disk = found_optic_disk + 1;
%                 fileID = fopen('train.dataset','at');
%                 fprintf(fileID, '"%s" 11, 1, %s\n', the_path, hog_to_string(optic_disk_image), ',', lbp_to_string(optic_disk_image));
%                 fclose(fileID);
%             case 'No'
%                 
%             case 'Cancel'
%                 return;
%         end
%         close 3;
%     end
end
end
