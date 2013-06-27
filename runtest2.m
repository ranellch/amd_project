xDoc= xmlread('images.xml');
images = xDoc.getElementsByTagName('image');
results = cell(1000,1);
loc = 1;
for i = 1:images.getLength-1
    image = images.item(i - 1);
    time = char(image.getAttribute('time'));
    patid = char(image.getAttribute('id'));
    if str2double(time) == 1 %test shit
            nextimage = images.item(i);
            if ~strcmpi(char(nextimage.getAttribute('id')),patid)
                break
            end
            visit1  =  char(image.getAttribute('path'));
            visit2 = char(nextimage.getAttribute('path'));
            trialname = strcat('-1v', num2str(j+1));
            data = compare_maculas_test(visit1, visit2, patid, trialname);
            results(loc:loc+length(fieldnames(data))-1) = struct2cell(data);
            loc = loc + length(fieldnames(data))+1;
    elseif str2double(time) == 2 % go to next patient
    continue
    end

end

xlswrite('results.xls',results); 
        
