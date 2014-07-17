function update_video_xml(pid, eye, time, attr, value)
    xmlfile = 'non_perfusion.xml';
    xDoc= xmlread(xmlfile);
    videos = xDoc.getElementsByTagName('video');
    
    path = [];
    found_it = 0;
	%Loop on the image field in the images tag
    for count=1:videos.getLength
        video = videos.item(count - 1);
        if strcmp(pid, char(video.getAttribute('id'))) == 1 && ...
           strcmp(time, char(video.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(video.getAttribute('eye'))) == 1
        	video.setAttribute(attr, value);
        end
    end
    
    if found_it == 0
        err = MException('MATLAB:paramAmbiguous', 'Could not find the video sequence in the XML database');
        throw(err);
    elseif ispc ~= 1
       xmlwrite(xmlfile);
    end
end