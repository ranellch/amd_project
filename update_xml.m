function update_xml(patient, eye, data, two_eyes)
% data = [files, dates]
labeled_path = '\Labeled\MCW';
original_path = '\Originals\MCW Pics (All)';
xDoc= xmlread('AMD images.xml');

%order by date to set time attribute
formatIn = 'mm/dd/yyyy';
for i = 1:size(data,1)
    data{i,2} = datenum(data{i,2},formatIn);
end

data = sortrows(data,2);

if two_eyes
    subfolder = [eye, '\'];
else 
    subfolder = [];
end

for i = 1:size(data,1)
    filename = data{i,1};
    path1 = [original_path, '\', patient, '\', subfolder, ...
                patient(1:2), '_', patient(3:4), '_', patient(5:6), '_', patient(7:8), '0', '_', filename, '.tif'];
    path2 = [labeled_path, '\', patient, '\', subfolder, ...
                patient(1:2), '_', patient(3:4), '_', patient(5:6), '_', patient(7:8), '0', '_', filename, '.tif'];
    newImage = xDoc.createElement('image');
    newImage.setAttribute('id',patient);
    newImage.setAttribute('eye', eye);
    newImage.setAttribute('original',path1);               
    newImage.setAttribute('AMD', path2);
    newImage.setAttribute('time',num2str(i));            
    xDoc.getDocumentElement.appendChild(newImage);

end

xmlwrite('AMD images.xml',xDoc);