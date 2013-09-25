%Add the location of the XML file with patient information
addpath('..');
    
%Add the location of the images
addpath(genpath('../Test Set'));

mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');

fid = fopen('train.dataset');
paths = textscan(fid,'%q %d %*[^\n]');
fclose(fid);

for x=1:size(paths{1}, 1)
    mapObj(char(paths{1}{x})) = paths{2}(x);
end

mapObjExclude = containers.Map('KeyType', 'char', 'ValueType', 'int32');
fid = fopen('exclude.dataset');
excludes = textscan(fid,'%q %*[^\n]');
fclose(fid);

for x=1:size(excludes{1}, 1)
    mapObjExclude(char(excludes{1}{x})) = 0;
end


xDoc= xmlread('images.xml');
images = xDoc.getElementsByTagName('image');

%Loop on the image field in the images tag
for count=1:images.getLength
    image = images.item(count - 1);
    
    %Get the path and load the image
    the_path = char(image.getAttribute('path'));
    image = imread(the_path);
    
    if isKey(mapObjExclude, the_path)
        disp(['Skipping: ', the_path]);
        continue;
    else
        disp(['Loading: ', the_path]);
    end

    if isKey(mapObj, the_path) == 0
        mapObj(the_path) = 0.0;
    end
    
    maxy = size(image, 1);
    maxx = size(image, 2);
    minimum_size = maxy / 3;
    
    subimages_count = 1;
    found_optic_disk = 0;
    while subimages_count <= 10
        if mapObj(the_path) < subimages_count
            [xs, xe, ys, ye] = random_box(maxx, maxy, minimum_size);
            subimage = image(ys:ye, xs:xe);

            figure(2);
            imshow(subimage);
            yesnobutton = questdlg('Does this image contain an optic disc?', [the_path, ' - ', num2str(subimages_count)],'Yes','No', 'Cancel', 'Cancel');
            switch yesnobutton
                case 'Yes'
                    found_optic_disk = found_optic_disk + 1;
                    subimages_count = subimages_count - 1;
                case 'No'
                    fileID = fopen('train.dataset','at');
                    fprintf(fileID, '"%s" %d, 0, %s\n', the_path, subimages_count, hog_to_string(subimage), ',', lbp_to_string(subimage));
                    fclose(fileID);
                case 'Cancel'
                    return;
            end
            close 2;
            mapObj(the_path) = subimages_count;
        end
        subimages_count = subimages_count + 1;
    end
    
    if mapObj(the_path) < 11
        figure(1);
        imshow(image);
        [centerx, centery] = ginput(1);
        close 1;
        
        xs = centerx(1) - (minimum_size / 2);
        if(xs <= 0)
            xs = 1;
        end
        xe = xs + minimum_size;
        
        ys = centery(1) - (minimum_size / 2);
        if(ys <= 0)
            ys = 1;
        end
        ye = ys + minimum_size;
        
        optic_disk_image = image(ys:ye, xs:xe);
        figure(3);
        imshow(optic_disk_image);
        yesnobutton = questdlg('Does this image contain an optic disc?','Optic Disc?','Yes','No', 'Cancel', 'Cancel');
        switch yesnobutton
            case 'Yes'
                found_optic_disk = found_optic_disk + 1;
                fileID = fopen('train.dataset','at');
                fprintf(fileID, '"%s" 11, 1, %s\n', the_path, hog_to_string(optic_disk_image), ',', lbp_to_string(optic_disk_image));
                fclose(fileID);
            case 'No'
                
            case 'Cancel'
                return;
        end
        close 3;
    end
end

