function [out] = get_cpt2points()
    %Add the path of the images to look for
    addpath(genpath('../Test Set'));
    
    %Add path for match_sizing.m
    addpath('../vessel_detection');

    %Opent the xml document
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');
    
    for count=1:images.getLength
        %Get the first image to iterate over
        image1xml = images.item(count - 1);
        id1 = char(image1xml.getAttribute('id'));
        path1 = char(image1xml.getAttribute('path'));
        time1 = char(image1xml.getAttribute('time'));
              
        %Get all correspondeing images for this id
        count2 = 1;

        %Read the base image into memory
        base = imread(path1);

        while count2<=images.getLength
            %Get the image to compare to for the given id
            image2xml = images.item(count2 - 1);
            id2 = char(image2xml.getAttribute('id'));
            path2 = char(image2xml.getAttribute('path'));
            time2 = char(image2xml.getAttribute('time'));
                
            if strcmpi(id1, id2) == 1 && strcmpi(time1, time2) == 0
                %Check this image pair to make sure that they have not already been compared
                alreadydone = 0;
                dx = 0;
                dy = 0;
                scale = 0;
                angle = 0;
                try
                    registered = image1xml.getElementsByTagName('reg');
                    regxml = '';
                    for regcount=1:registered.getLength
                        regxml = registered.item(regcount - 1);
                        timeid = char(regxml.getAttribute('corr_time'));

                        if(strcmpi(timeid, time2) == 1)
                            alreadydone = 1;
                        end
                    end

                    %If already exists then read it from the xml file
                    if(alreadydone == 1)
                        dx = return_xyas(regxml, 'dx');
                        dy = return_xyas(regxml, 'dy');
                        scale = return_xyas(regxml, 'scale');
                        angle =return_xyas(regxml, 'angle');
                    end
                catch
                    alreadydone = 0;
                end

                %If not already bee compared then use cpselect to determine transform
                if(alreadydone == 0)
                    %Create result xml node
                    reg_xmlf = xDoc.createElement('reg');
                    reg_xmlb = xDoc.createElement('reg');
                    reg_xmlf.setAttribute('corr_time', time2);
                    reg_xmlb.setAttribute('corr_time', time1);

                    %Read in the next image to corr
                    next = imread(path2);

                    %Resize the image so that they are both the same now
                    [image1, image2] = match_sizing(next, base);

                    %Use cpselect tool to put them together and get affine transform
                    [xyinput_out, xybase_out] = cpselect(image2, image1, 'Wait', true);
                    if size(xyinput_out, 1) >= 3 && size(xybase_out, 1) >= 3 && size(xyinput_out, 1) == size(xybase_out, 1)
                        [angle, scale, translation, tform] = transform_it_vision(xybase_out, xyinput_out);

                        %get the x offset
                        dx = translation(1);
                        x_xml = xDoc.createElement('dx');
                        x_xml.setTextContent(num2str(dx));
                        reg_xmlf.appendChild(x_xml);
                        x_xml = xDoc.createElement('dx');
                        x_xml.setTextContent(num2str(-1.0 * dx));
                        reg_xmlb.appendChild(x_xml);

                        %Get the yoffset
                        dy = translation(2);
                        y_xml = xDoc.createElement('dy');
                        y_xml.setTextContent(num2str(dy));
                        reg_xmlf.appendChild(y_xml);
                        y_xml = xDoc.createElement('dy');
                        y_xml.setTextContent(num2str(-1.0 * dy));
                        reg_xmlb.appendChild(y_xml);

                        %Get the angle offset
                        a_xml = xDoc.createElement('angle');
                        a_xml.setTextContent(num2str(angle));
                        reg_xmlf.appendChild(a_xml);
                        a_xml = xDoc.createElement('angle');
                        a_xml.setTextContent(num2str(-1.0 * angle));
                        reg_xmlb.appendChild(a_xml);

                        %Get the scale offset
                        s_xml = xDoc.createElement('scale');
                        s_xml.setTextContent(num2str(scale));
                        reg_xmlf.appendChild(s_xml);
                        s_xml = xDoc.createElement('scale');
                        s_xml.setTextContent(num2str(1.0 / scale));
                        reg_xmlb.appendChild(s_xml);

                        %apply the transform and display to use so one can seeit
                        [img1_correct, img2_correct] = apply_transform(tform, image1, image2);
                        pairhandle = imshowpair(img1_correct, img2_correct);
                        waitfor(pairhandle);

                        % Construct a questdlg with three options
                        choice = questdlg('Would you like use this match?', ...
                                            'Valid Match', 'Yes', 'No', 'No');
                        % Handle response
                        switch choice
                            case 'Yes'
                                %Add the new tag and write the output
                                image1xml.appendChild(reg_xmlf);
                                image2xml.appendChild(reg_xmlb);
                                xmlwrite('images.xml', xDoc);
                            case 'No'
                                disp('Ok does not sound good!');
                        end
                    else
                        disp('You have not entered enough points (minimum of 3) and/or matching points');
                    end
                end
                
                %Disp the transform calculated or already stored
                disp([id1, ' ', path1, ' - ', path2, ...
                    ' => theta: ', num2str(angle), ' scale: ', num2str(scale),...
                    ' x: ', num2str(dx), ' y: ', num2str(dy)]);
            end

            %Move onto next image
            count2 = count2 + 1;
        end
    end
end

function [number] = return_xyas(xmlhandle, value)
    number = 0;
    output = xmlhandle.getElementsByTagName(value);
	for count=1:output.getLength
        xml = output.item(count - 1);
        number = str2double(xml.getTextContent);
    end
end

