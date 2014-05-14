    %Updates time column in excel sheet

    [~,patients,~] = xlsread('Database of all images.xlsx', 'All images', 'B2:B154');
    [~,files,~] = xlsread('Database of all images.xlsx', 'All images', 'C2:C154');
    
    xDoc= xmlread('AMD images.xml');
    images = xDoc.getElementsByTagName('image');
    times = [];
  
    for i = 1:length(patients)
        patient = patients(i);
        file = files(i);

        %Loop on the image field in the images tag
        for count=1:images.getLength
            image = images.item(count - 1);

            if strcmp(patient, char(image.getAttribute('id'))) 
                fullpath = char(image.getAttribute('original'));
                xmlfilename = fullpath((end-6):(end-4));
                if strcmp(file, xmlfilename) 
                    time = char(image.getAttribute('time'));
                end
            end
        end
        times = [times; time];
    end
    
    xlswrite('Database of all images.xlsx', times, 'S2:S154');
    
        