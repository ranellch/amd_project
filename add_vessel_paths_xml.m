function add_vessel_paths_xml(pid)
    %Edit this line below to add new images to the xml
    image_type = 'vessels';
    
    %Have user select an image and then get the relative path
    try
        [filename,pathuser,~] = uigetfile('Test Set\*.*');
        rel_path = strsplit(pathuser,'Test Set\');
        path = ([rel_path{1,2}, filename]);
        path = strrep(path, '/','\');
    catch err
        getReport(err)
        disp('Error in selecting a file');
        return;
    end

    %Get the user input for eye side
    eye_choice = menu('Choose the eye!','OD','OS');
    if(eye_choice == 1)
        eye = 'OD';
    elseif(eye_choice == 2)
        eye = 'OS';
    else
        disp('Error in selecting an appropiate eye side!');
        return;
    end
    
    %Get the timing information
    try
        time_input = inputdlg('Input the timing number: ','Timing Number Information');
        time_test = num2str(time_input{:});
        time = time_input{:};
    catch
        disp('Error in inputting a number can only input a number!');
        return;
    end
    
    xDoc= xmlread('AMD images.xml');
    images = xDoc.getElementsByTagName('image');
    inserted = 0;
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        if strcmp(pid, char(image.getAttribute('id'))) == 1 && ...
           strcmp(time, char(image.getAttribute('time'))) == 1 
        	image.setAttribute(image_type,path);
            image.setAttribute('eye',eye);
            inserted = 1;
            break;
        end
    end
    
    if inserted == 0
        disp(['Error: could not find pid:',  pid, ' time: ', time]); 
        return;
    end
    
    xmlwrite('AMD images.xml',xDoc);
end