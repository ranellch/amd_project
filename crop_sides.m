%removes all weird 36 pixel overlaps from other image
fid = fopen('control images.txt', 'r');
images = textscan(fid,'%q %q %d %*[^\n]');
fclose(fid);

addpath(genpath('./Test Set'));

numimages = size(images{1},1);
savedir = './cropped/';
if ~isdir(savedir)
    mkdir(savedir);
end

for i = 1:numimages
    pid = char(images{1}{i});
    eye = char(images{2}{i});
    time = num2str(images{3}(i));
    path = get_pathv2(pid,eye,time,'AMD');
    [~,name,~] = fileparts(path); 
    img = imread(path);
    if strcmp(eye,'OD')
        img = img(:,1:end-36,:);
    else
        img = img(:,37:end,:);
    end
    imwrite(img,[savedir,name,'.tif'],'tiff');
end
    