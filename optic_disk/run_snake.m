function img = run_snake()
addpath('snake');

%Add the location of the XML file with patient information
addpath('..');
    
%Add the location of the images
addpath(genpath('../Test Set'));

mapObj = containers.Map('KeyType', 'char', 'ValueType', 'int32');

fid = fopen('snaked.dataset');
paths = textscan(fid,'%q %*[^\n]');
fclose(fid);

for x=1:size(paths{1}, 1)
    mapObj(char(paths{1}{x})) = 1;
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
    img = imread(the_path);
    
    if isKey(mapObjExclude, the_path) || isKey(mapObj, the_path)
        disp(['Skipping: ', the_path]);
        continue;
    else
        disp(['Loading: ', the_path]);
    end

    if isKey(mapObj, the_path) == 0
        mapObj(the_path) = 0.0;
    end
    
    img = im2double(img);

    figure, imshow(img);
    [ycoord, xcoord] = ginput(8);
    
    P = zeros(length(ycoord), 2);
    pindex = 1;
    for i=1:length(ycoord)
        P(pindex, 1) = xcoord(i);
        P(pindex, 2) = ycoord(i);
        pindex = pindex + 1;
    end

    Options=struct;
    Options.Verbose=true;
    Options.Iterations=400;
    Options.Wedge=3;

    [~,J] = Snake2D(img, P, Options);
    

    yesnobutton = questdlg('Does this snaking look good?...Bwhahahaha!', the_path,'Yes','No', 'Cancel', 'Cancel');
    switch yesnobutton
        case 'Yes'
            imwrite(J, ['snaked\', the_path], 'jpg');
            fileID = fopen('snaked.dataset','at');
            fprintf(fileID, '"%s"\n', the_path);
            fclose(fileID);
        case 'No'

        case 'Cancel'
            return;
    end
end

end