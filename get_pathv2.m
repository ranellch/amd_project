function [path] = get_pathv2(pid, eye, time, type)
    %Parse XML document and find this pictures information, return empty
    %array if not found
    xDoc= xmlread('AMD images.xml');
    images = xDoc.getElementsByTagName('image');
    path = [];
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        if strcmp(pid, char(image.getAttribute('id'))) == 1 && ...
           strcmp(time, char(image.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(image.getAttribute('eye'))) == 1
        	path = char(image.getAttribute(type));
        end
    end
    
    if ispc ~= 1
       path = strrep(path, '\', '/');
    end
end