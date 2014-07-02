%Prompts user to click on the location of the fovea in every image listed
%in the text file
%Saves x and y coords in xml 
fid = fopen('control images.txt', 'r');
images = textscan(fid,'%q %q %d %*[^\n]');
fclose(fid);

numimages = size(images{1},1);

xDoc= xmlread('AMD images.xml');
xml_images = xDoc.getElementsByTagName('image');

for i = 1:numimages
    pid = char(images{1}{i});
    eye = char(images{2}{i});
    time = num2str(images{3}(i));
    
    path = get_pathv2(pid,eye,time,'original');
    img = imread(path);
    figure(1),imshow(img)
    [x,y] = ginput(1);
    %Loop on the image field in the images tag
    for count=1:xml_images.getLength
        thisimage = xml_images.item(count - 1);

        if strcmp(pid, char(thisimage.getAttribute('id'))) == 1 && ...
           strcmp(time, char(thisimage.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(thisimage.getAttribute('eye'))) == 1
       
            thisimageChildren = thisimage.getChildNodes;
            %ignore 0th element (whitespace node)
            fovea = thisimageChildren.item(1);     
            if(length(char(fovea)) <= 0)
                fovea = xDoc.createElement('fovea');
                fovea.setAttribute('x',num2str(round(x)));
                fovea.setAttribute('y',num2str(round(y)));
                thisimage.appendChild(fovea);
            else
                fovea.setAttribute('x',num2str(round(x)));
                fovea.setAttribute('y',num2str(round(y)));
            end
            break
        end
    end
end

xmlwrite('AMD images.xml',xDoc);