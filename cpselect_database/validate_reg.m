function [out] = validate_reg()
    %Add the path for the set of images to test
    addpath(genpath('../Test Set'));
    addpath('../vessel_detection');
    addpath('../vessel_detection/crosscoor');
    
    %Parse XML document and find this pictures information
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');
    
    filename = 'exp.csv';
    if exist(filename) ~= 0
        readfile = fopen(filename,'r');
        mydata = textscan(readfile, '%*s %*s %*s %*[^\n]', 'delimiter', ',');
        fclose(readfile);
    else
        outputfile = fopen(filename,'w');
        fprintf(outputfile, 'id, time1, time2, runtime, x1, y1, theta1, scale1, x2, y2, theta2, scale2\n');
        fclose(outputfile);
    end
          
    for count1=1:images.getLength
        image1 = images.item(count1 - 1);
        id1 = char(image1.getAttribute('id'));
        path1 = char(image1.getAttribute('path'));
        time1 = char(image1.getAttribute('time'));
        transform1 = get_transform(image1);
                
        for count2=1:images.getLength
            image2 = images.item(count2 - 1);
            id2 = char(image2.getAttribute('id'));
            path2 = char(image2.getAttribute('path'));
            time2 = char(image2.getAttribute('time'));
            transform2 = get_transform(image2);
            
            if strcmp(id1, id2) == 1 && strcmp(time1, time2) == 0
                               
                disp('================================================');
                disp([id1, ': ', time1, ' => ', time2]);
                
                %Read in the files to attempt to register
                base_img_real = imread(path1);
                next_img_real = imread(path2);

                %Apply necessary transforms to images to prepare for vessel detection
                base_img_vd = prepare_image(base_img_real, transform1);
                next_img_vd = prepare_image(next_img_real, transform2);

                %Get the vessel outline of each image
                disp('Running Vessel Dectection');
                base_img = vessel_detection(base_img_vd);
                next_img = vessel_detection(next_img_vd);
                
                %Convert images to doubles
                base_img = im2double(base_img)/256;
                next_img = im2double(next_img)/256;
    
                %Resize the images to be the same size
                [base_img, next_img] = match_sizing(base_img, next_img);     
                
                %Run Correlation Correspondance
                cc = correlCorresp('image1', base_img, 'image2', next_img);
                %Increase this value to decrease the number of featues
                cc.relThresh = 0.5;
                %Decrease this value to make the matches more precise
                %Decrease this value also increases time to run
                cc.convTol = 0.1;
                %Set value to 2 for more less strict reverse matching
                %Set value to 1 for more strict revserse matching
                cc.matchTol = 2;
                
                skip_quad = zeros(1,1);
                skip_quad(1, 1) = 5;
                quad_count = 3;
    
                %Run the sliding crossCorr
                disp('Running Correlation Correspondance');
                t = cputime;
                cc = cc.findCorresps;
                t = cputime - t;
                disp(['Correlation Time: ', num2str(t), ' seconds']);
                
                minx = size(base_img, 2);
                miny = size(base_img, 1);
                
                %Get the most common points in each quad
                temp = most_common(cc.corresps, quad_count, skip_quad, minx, miny);

                %Display the original set of matched points
                %figure(1);
                %correspDisplay(cc.corresps, temp);

                %Form arry in the correct manner
                pointsA = temp(1:2,:)';
                pointsB = temp(3:4,:)';

                %Estimate the image transform
                [theta2, scale2, translation2, ~] = transform_it_vision(pointsA, pointsB);
                xtrans2 = translation2(1);
                ytrans2 = translation2(2);
                disp(['Algorithmic output -> x: ', num2str(xtrans2), ' y: ', num2str(ytrans2), ' theta: ', num2str(theta2), ' scale: ', num2str(scale2)]);
                
                %Get the hand calculated transform from the xml
                [theta1, scale1, xtrans1, ytrans1] = get_trans_xml(image1, time2);
                disp(['Users Input output -> x: ', num2str(xtrans1), ' y: ', num2str(ytrans1), ' theta: ', num2str(theta1), ' scale: ',num2str(scale1)]);
                
                outputfile = fopen(filename,'at');
                fprintf(outputfile, '%s, %s, %s, %f, %f, %f, %f, %f, %f, %f, %f, %f\n', id1, time1, time2, t, xtrans1, ytrans1, theta1, scale1, xtrans2, ytrans2, theta2, scale2);
                fclose(outputfile);
            end
        end
    end
end

function [theta, scale, xtrans, ytrans] = get_trans_xml(image_xml, time)
    time_xmls = image_xml.getElementsByTagName('reg');
    theta = 0;
    scale = 0;
    xtrans = 0;
    ytrans = 0;
    
    for count=1:time_xmls.getLength
        time_xml = time_xmls.item(count - 1);
        time_reg = char(time_xml.getAttribute('corr_time'));
        
        if strcmp(time_reg, time) == 1
            xtrans = get_child_value(time_xml, 'dx');
            ytrans = get_child_value(time_xml, 'dy');
            theta = get_child_value(time_xml, 'angle');
            scale = get_child_value(time_xml, 'scale');
        end
    end
end

function [out] = get_child_value(time_xml, index)
    out = 0;
    try
        val = time_xml.getElementsByTagName(index);
        if val.getLength == 1
            out = str2double(val.item(0).getTextContent);
        else
        	out = 0; 
        end
    catch
       out = 0; 
    end
end

function [out] = get_transform(image_xml)
    out = 'none';
	try
        out = char(image_xml.getAttribute('transform'));
    catch 
        out = 'none';
    end
end
