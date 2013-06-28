xDoc= xmlread('images.xml');
images = xDoc.getElementsByTagName('image');
results = cell(1000,1);
loc = 1;
for i = 1:images.getLength-1
    image = images.item(i - 1);
    time = char(image.getAttribute('time'));
    patid = char(image.getAttribute('id'));
    type = char(image.getAttribute('type')); 
    corr = char(image.getAttribute('corr'));
    if strcmpi(type,'base') % start with base
        for count = 1:images.getLength  
             nextimage = images.item(count - 1);
             nextid = char(nextimage.getAttribute('id'));
             nexttype = char(nextimage.getAttribute('type')); 
             nexttime = char(nextimage.getAttribute('time'));
            if all([strcmpi(nextid, patid), strcmpi(nexttype,'corr'),str2double(nexttime) == str2double(corr)])
                visit1 =  char(image.getAttribute('path'));
                visit2 = char(nextimage.getAttribute('path'));
                trialname = strcat('-', time, 'v', nexttime);
                data = compare_maculas_best('AF',visit1, visit2, patid, trialname);
                results(loc:loc+length(fieldnames(data))-1) = struct2cell(data);
                loc = loc + length(fieldnames(data))+1;
            end
        end           
    elseif  strcmpi(type,'corr') % go to next patient
    continue
    end

end

xlswrite('results.xls',results); 
        
