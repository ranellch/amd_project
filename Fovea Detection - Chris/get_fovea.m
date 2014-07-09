function [x,y] = get_fovea(pid, eye, time)
    %Parse XML document and find this pictures information, return empty
    %array if not found
    xDoc= xmlread('../AMD images.xml');
    images = xDoc.getElementsByTagName('image');
    x = [];
    y = [];
    found_it = 0;
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        if strcmp(pid, char(image.getAttribute('id'))) == 1 && ...
           strcmp(time, char(image.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(image.getAttribute('eye'))) == 1
        	 imageChildren = image.getChildNodes;
            %ignore 0th element (whitespace node)
            fovea = imageChildren.item(1); 
            x = str2double(fovea.getAttribute('x'));
            y = str2double(fovea.getAttribute('y'));
            found_it = 1;
        end
    end
    
    if found_it == 0
        err = MException('MATLAB:paramAmbiguous', 'Could not find the image in the XML database');
        throw(err);
    end
end