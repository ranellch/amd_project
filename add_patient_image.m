function add_patient_image(pid, varargin)
    if(length(varargin) > 2)
        disp('Error too many input arguements');
        return;
    end

    %Edit this line below to add new images to the xml
    image_type = 'vessels';
    disp(['You are entereing image type => ', image_type]);
    
    if ispc
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
    else
        %Have user select an image and then get the relative path
        try
            [filename,pathuser,~] = uigetfile('Test Set/*.*');
            rel_path = strsplit(pathuser,'Test Set/');
            path = ([rel_path{1,2}, filename]);
            path = strrep(path, '/','\');
        catch err
            getReport(err)
            disp('Error in selecting a file');
            return;
        end
    end

    if(~isempty(varargin) && (strcmp(varargin{1}, 'OD') == 1 || strcmp(varargin{1}, 'OS') == 1))
        eye = varargin{1};
    else
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
    end
    
    %Get the timing information
    try
        time = -1;
        try
            if(~isempty(varargin))
                tempnum = num2str(varargin{2});
                tempconv = num2str(tempnum);
                time = tempnum;
            end
        catch
        end
        
        if(time <= 0)
            time_input = inputdlg('Input the timing number: ','Timing Number Information');
            time_test = num2str(time_input{:});
            time = time_input{:};
        end
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
           strcmp(time, char(image.getAttribute('time'))) == 1 && ...
           strcmp(eye, char(image.getAttribute('eye'))) == 1
            
           try
                attrexists = image.getAttribute(image_type);
                if(length(char(attrexists)) <= 0)
                    image.setAttribute(image_type,path);
                    inserted = 1;
                else
                    disp(['The tag ', image_type, ' already exists!']);
                    inserted = -1;
                end
           catch
                
           end
            
            break;
        end
    end
    
    if inserted == 0
        disp(['Error: could not find pid: ',  pid, ' time: ', time]); 
        return;
    end
    
    xmlwrite('AMD images.xml',xDoc);
end