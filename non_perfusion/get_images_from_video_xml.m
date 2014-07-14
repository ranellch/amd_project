function [count, paths, times] = get_images_from_video_xml(video_path)
    xDoc= xmlread(video_path);
    frames = xDoc.getElementsByTagName('frame');
    
    padding = 200;
    
    count = 0;
    paths=[];
    times=[];
    
    %Loop on the frame field in the images tag
    for count=1:frames.getLength
        frame = frames.item(count - 1);

        path = char(frame.getAttribute('registered'));
        if ispc ~= 1
            newpath = strrep(path, '\', '/');
        end
        paths = [paths; newpath];
        
        times = [times; char(frame.getAttribute('time'))];
        count = count + 1;
    end
end