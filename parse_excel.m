[~,~,nums] = xlsread('Database of all images.xlsx', 'All images', 'A2:A154');
[~,patients,~] = xlsread('Database of all images.xlsx', 'All images', 'B2:B154');
[~,files,~] = xlsread('Database of all images.xlsx', 'All images', 'C2:C154');
[~,eyes,~] = xlsread('Database of all images.xlsx', 'All images', 'O2:O154');
[~,dates,~] = xlsread('Database of all images.xlsx', 'All images', 'K2:K154');
data = [nums, patients, files, eyes, dates];
numpatients = 25;

for i = 1:numpatients
    patimgs = [];
    
    %get all images from the same patient
    for j=1:length(data)
        if data{j,1} == i
            patimgs = [patimgs; data(j,:)];
        end
    end
    
    patient = patimgs{1,2};
    disp(['Reading patient ', patient]);
    
    %check if two different eyes are present
    two_eyes = false;
    for j = 1:size(patimgs,1);
        if ~strcmp(patimgs(j,4),patimgs(1,4))
            two_eyes = true;
            break
        end
    end
    
    %if there are two different eyes, split the set 
    if two_eyes
        patimgsOS = patimgs(strcmp('OS',patimgs(:,4)),:);
        update_xml(patient, 'OS', [patimgsOS(:,3), patimgsOS(:,5)],two_eyes);
        patimgsOD = patimgs(strcmp('OD',patimgs(:,4)),:);
        update_xml(patient, 'OD', [patimgsOD(:,3), patimgsOD(:,5)],two_eyes);
    else
        eye = patimgs{1,4};
        update_xml(patient, eye, [patimgs(:,3), patimgs(:,5)],two_eyes);
    end
end