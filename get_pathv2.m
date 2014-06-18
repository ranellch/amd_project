function [path] = get_pathv2(pid, eye, time, type)
    %Parse XML document and find this pictures information, return empty
    %array if not found
    xDoc= xmlread('AMD images.xml');
    images = xDoc.getElementsByTagName('image');
    path = [];
    found_it = 0;
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        if strcmp(pid, char(image.getAttribute('id'))) == 1 && ...
           strcmp(time, char(image.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(image.getAttribute('eye'))) == 1
        	path = char(image.getAttribute(type));
            found_it = 1;
        end
    end
    
    if found_it == 0
        err = MException('MATLAB:paramAmbiguous', 'Could not find the image in the XML database');
        throw(err);
    elseif ispc ~= 1
       path = strrep(path, '\', '/');
    end
end