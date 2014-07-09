%removes all footers from images specified in text file
fid = fopen('mcw images.txt', 'r');
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
    img = crop_footer(img);
    imwrite(img,[savedir,name,'.tif'],'tiff');
end
    