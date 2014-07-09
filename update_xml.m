function update_xml(pid,eye,time,field,data)

xDoc= xmlread('AMD images.xml');
xml_images = xDoc.getElementsByTagName('image');

for i = 1:numimages
    
    %Loop on the image field in the images tag
    for count=1:xml_images.getLength
        thisimage = xml_images.item(count - 1);

        if strcmp(pid, char(thisimage.getAttribute('id'))) == 1 && ...
           strcmp(time, char(thisimage.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(thisimage.getAttribute('eye'))) == 1
                thisimage.setAttribute(field,data);
            break
        end
    end
end

xmlwrite('AMD images.xml',xDoc);