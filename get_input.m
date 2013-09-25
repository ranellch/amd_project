function [] = get_input()
    addpath(genpath('Test Set'));
    
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');
    
    for count=1:images.getLength
        image = images.item(count - 1);
    
        the_path = '';
        try
            the_path = char(image.getAttribute('path'));
            img = imread(the_path);
        catch
            
        end
        
        cont = 0;
        try
            macula_thing = image.getElementsByTagName('macula');
            if(macula_thing.getLength == 0)
                 cont = 1;
            end
        catch
            cont = 1;
        end
        
        try
            optic_thing = image.getElementsByTagName('optic_disk');
            if(optic_thing.getLength == 0)
                 cont = 1;
            end
        catch
            cont = 1;
        end

        if cont == 0
            continue; 
        end
        
        img = imread(the_path);
        figure(1);imshow(img);title(the_path);
        [xin,yin] = ginput(2);

        macula_xml = xDoc.createElement('macula');
        macula_x = round(xin(1));
        x = xDoc.createElement('x');
        x.appendChild(xDoc.createTextNode(sprintf('%i',macula_x)));
        macula_xml.appendChild(x);

        macula_y = round(yin(1));
        y = xDoc.createElement('y');
        y.appendChild(xDoc.createTextNode(sprintf('%i',macula_y)));
        macula_xml.appendChild(y);

        optic_xml = xDoc.createElement('optic_disk');
        optic_x = round(xin(2));
        x = xDoc.createElement('x');
        x.appendChild(xDoc.createTextNode(sprintf('%i',optic_x)));
        optic_xml.appendChild(x);

        optic_y = round(yin(2));
        y = xDoc.createElement('y');
        y.appendChild(xDoc.createTextNode(sprintf('%i',optic_y)));
        optic_xml.appendChild(y);

        image.appendChild(macula_xml);
        image.appendChild(optic_xml);
    
        xmlwrite('images_out.xml', xDoc);
    end
    
    
        
end

