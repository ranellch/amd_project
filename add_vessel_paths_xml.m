function add_vessel_paths_xml(pid, time, eye, path)
    xDoc= xmlread('AMD images.xml');
    images = xDoc.getElementsByTagName('image');
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        if strcmp(pid, char(image.getAttribute('id'))) == 1 && ...
           strcmp(time, char(image.getAttribute('time'))) == 1 
        	image.setAttribute('vessels',path);
            image.setAttribute('eye',eye);
            break
        end
    end
    xmlwrite('AMD images.xml',xDoc);
end