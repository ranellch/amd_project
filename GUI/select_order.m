% Script to interface with GUI and prompt user to put images from all MCW eyes in
% order by time 
addpath(genpath('../Test Set'))
addpath('..')

[nums,~,~] = xlsread('../Database of all images.xlsx', 'All images', 'A2:A154');
[~,patients,~] = xlsread('../Database of all images.xlsx', 'All images', 'B2:B154');
[~,eyes,~] = xlsread('../Database of all images.xlsx', 'All images', 'O2:O154');
[times,~,~] = xlsread('../Database of all images.xlsx', 'All images', 'S2:S154');
numpatients = 25;
current_row  = 1;

% get number of columns currently written in excel file, add one to write
% to next available column
[~, txt, ] = xlsread('../Database of all images.xlsx', 'All images');
col = size(txt, 2) + 1;
col = col+1;
col_letter = char(xlsColNum2Str(col));

% Prompt user for name
 username = inputdlg('Enter your name');
 if isempty(username)
     return
 end
 xlswrite('../Database of all images.xlsx', username, 'All images', [col_letter,'1:',col_letter,'1']);
 
for i = 25:numpatients
    %get current patient
    while nums(current_row) ~= i
        current_row = current_row +1;
    end
    patid = patients{current_row};
    
    imgdata = [];
    %get eyes and times for xml
    j = current_row;
    for j=current_row:length(patients) 
        if strcmp(patients{j},patid) 
            imgdata = [imgdata; [eyes(j), num2str(times(j))]];
        else 
            break
        end
    end
    
    paths = {};
    %get all paths
    for j = 1:length(imgdata)
        paths = [paths; get_pathv2(patid, imgdata{j,1}, imgdata{j,2}, 'original')];
    end
    
    %separate OS and OD runs
    OSimgs = strcmp(imgdata(:,1),'OS');
    ODimgs = strcmp(imgdata(:,1),'OD');
    
    round_output = zeros(length(paths),1);
    
    %OS
    if any(strcmp(imgdata(:,1),'OS'))
        %have user order images
        [OSresults, stop] = TimeSelection(paths(OSimgs));
        if stop
            break
        else
            round_output(OSimgs) = OSresults';
        end
    end
    
    %OD
     if any(strcmp(imgdata(:,1),'OD'))
        %have user order images
        [ODresults, stop] = TimeSelection(paths(ODimgs));
        if stop
            break
        else
            round_output(ODimgs) = ODresults';
        end
     end
     
     %Write results to excel
     range = sprintf([col_letter, '%i:', col_letter,'%i'], [current_row+1, current_row+length(paths)+1]);
     xlswrite('../Database of all images.xlsx', round_output, 'All images', range);
     
end
