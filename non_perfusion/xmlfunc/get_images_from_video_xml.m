function [counter, paths, times] = get_images_from_video_xml(video_path)
    xDoc= xmlread(video_path);
    frames = xDoc.getElementsByTagName('frame');
    
    path_padding = 200;
    timing_padding = 50;
    
    counter = 0;
    paths=[];
    times=[];
    
    %Loop on the frame field in the images tag
    for count=1:frames.getLength
        frame = frames.item(count - 1);

        path = char(frame.getAttribute('path'));
        if ispc ~= 1
            newpath = strrep(path, '\', '/');
        else
            newpath = path;
        end
        
        if length(newpath) ~= path_padding
            topad = blanks(path_padding - length(newpath));
            newpath = [newpath topad];
        end
        paths = [paths; newpath];

        time = char(frame.getAttribute('time'));
        if length(time) ~= timing_padding
            topad = blanks(timing_padding - length(time));
            time = [time topad];
        end
        times = [times; time];
        
        counter = counter + 1;
    end
    
    paths = cellstr(paths);
    times = cellstr(times);
end