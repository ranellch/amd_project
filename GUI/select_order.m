% Script to interface with GUI and prompt user to put images from all MCW eyes in
% order by time 
addpath(genpath('../Test Set'))
addpath('..')
numrows = 154;

[nums,~,~] = xlsread('../Database of all images.xlsx', 'All images', ['A2:A', num2str(numrows)]);
[~,patients,~] = xlsread('../Database of all images.xlsx', 'All images', ['B2:B', num2str(numrows)]);
[~,eyes,~] = xlsread('../Database of all images.xlsx', 'All images', ['O2:O',num2str(numrows)] );
[times,~,~] = xlsread('../Database of all images.xlsx', 'All images', ['S2:S',num2str(numrows)]);
numeyes = 36;
output = cell(numrows,1);

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
 output(1) = username;
 
eye_nums = randperm(numeyes);
count = 1;
for i = eye_nums
    disp(i)
    %get current patient
    for j = 1:numrows-1
        if nums(j) == i
            current_row = j;
            break
        end
    end
    patid = patients{current_row};
    eye = eyes{current_row};
    
    imgdata = {};
    %get times for xml
    for j=current_row:length(patients) 
        if strcmp(patients{j},patid) && strcmp(eyes{j}, eye) 
            imgdata = [imgdata; num2str(times(j))];
        else 
            break
        end
    end
    
    paths = {};
    %get all paths
    for j = 1:length(imgdata)
        paths = [paths; get_pathv2(patid, eye, imgdata{j}, 'original')];
    end

    %have user order images
    [results, stop, handle] = TimeSelection(paths, count);
    if stop
        break
    else
        output(current_row+1:current_row+length(paths)) = num2cell(results');
    end 
   
    count = count + 1;
end

%Write output to excel
 range = sprintf([col_letter, '%i:', col_letter,'%i'], [1, numrows]);
 xlswrite('../Database of all images.xlsx', output, 'All images', range);

