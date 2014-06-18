function add_new_patient(pid)
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
    
    %Open the XML and search to make sure this tag hasn't already been added
    xDoc= xmlread('AMD images.xml');
    images = xDoc.getElementsByTagName('image');
    inserted = 0;
    for count=1:images.getLength
        image = images.item(count - 1);

        if strcmp(pid, char(image.getAttribute('id'))) == 1 && ...
           strcmp(time, char(image.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(image.getAttribute('eye'))) == 1
            inserted = 1;
            break;
        end
    end
    
    if inserted == 1
        disp(['Error: the following pid:',  pid, ' time: ', time, ' eye: ',  eye, 'already exists']); 
    else
        image_insert = xDoc.createElement('image');
        image_insert.setAttribute('id', pid);
        image_insert.setAttribute('eye', eye);
        image_insert.setAttribute('time', time);
        xDoc.getDocumentElement.appendChild(image_insert);
        xmlwrite('AMD images.xml',xDoc);
    end
end