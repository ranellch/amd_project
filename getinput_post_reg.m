
    xDoc= xmlread('reg_images.xml');
    list=dir('./results/');
    list = setdiff({list.name},{'.','..','.DS_Store'});
    
    imgDoc = xmlread('images.xml');
    images = imgDoc.getElementsByTagName('image');
    
    for i=1:length(list)
        
        if isdir(list{i})
            id=list{i};
            path = strcat('./results/',list{i},'/');
            sublist = dir(path);
            pics = setdiff({sublist.name},{'.','..','.DS_Store'});
             for j=1:length(pics)
                file = pics{j};
                [~, regname,~] = fileparts(file);

                if isequal(file,0)
                    error('Error in specifiying the file');
                end

                
                newImage = xDoc.createElement('image');
                
               
                
                if ~isempty(strfind(file,'_corrimg'));
                    type = 'corr';
                elseif ~isempty(strfind(file,'_baseimg'));
                    type = 'base';
                else 
                    error('Error: Images do not appear to be registered');                
                end
    
                    
                if strcmpi(type,'base')
                                         
                    index  = strfind(regname,'-');
                    identifier = regname(1:index-1);
                    
                    
                    for count = 1:images.getLength
                        image = images.item(count - 1);
                        if strcmpi(id, image.getAttribute('id'))
                            xmlpath = char(image.getAttribute('path'));
                            [~, name, ~] = fileparts(xmlpath);
                                if strcmpi(name,identifier);
                                    time = char(image.getAttribute('time'));
                                    break
                                end
                        end
                    end
                    
                    img = imread(strcat(path, file));
                    figure(1);imshow(img);title(file);
                   
                    disp('Select fovea then select optic Disk')
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

                    newImage.appendChild(macula_xml);
                    newImage.appendChild(optic_xml);
                    
                elseif strcmpi(type, 'corr')
                    
                    index  = strfind(regname,'-');
                    endindex = strfind(regname,'_corrimg');
                    identifier = regname(index+1:endindex-1);
                    
                    for count = 1:images.getLength
                        image = images.item(count - 1);
                        if strcmpi(id, image.getAttribute('id'))
                            xmlpath = char(image.getAttribute('path'));
                            [~, name, ~] = fileparts(xmlpath);
                                if strcmpi(name,identifier);
                                    time = char(image.getAttribute('time'));
                                    break
                                end
                        end
                    end
                end
                
                newImage.setAttribute('path', file);               
                newImage.setAttribute('id',id);
                newImage.setAttribute('time',time);
              
                xDoc.getDocumentElement.appendChild(newImage);

                xmlwrite('reg_images.xml', newImage);
             end
        end
    end

