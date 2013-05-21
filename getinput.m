function [good] = getinput()
    xDoc= xmlread('images.xml');
    images = xDoc.getElementsByTagName('image');
    
    newImage = xDoc.createElement('image');
    
    [file, path] = uigetfile('*.*');
    
    if isequal(file,0)
        error('Error in specifiying the file');
    end
    
    img = imread(strcat(path, '\', file));
    
    figure;image(img);
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
    
    pid = inputdlg('Enter the patient id:');
    time = inputdlg(strcat('Enter the sequence number of this image from patient (', pid , '):'));
    
	newImage.setAttribute('id', pid);
	newImage.setAttribute('time', time);
    newImage.setAttribute('path', file);
    newImage.appendChild(macula_xml);
    newImage.appendChild(optic_xml);
    
    xDoc.getDocumentElement.appendChild(newImage);
    
    xmlwrite('images.xml', newImage);
        
end

