% close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-007';
visit = '1 year';
refID = 'Dr.J';
referencefolder = 'manualRefs';
refpath = fullfile(alldatafolder, referencefolder, ...
    sprintf('Outline %s-%s-%s.jpg', pID, visit, refID) );

manualRef = imread(refpath);
size_record = size(manualRef, 2);
% convert red filled reference result to binary mask as well
reflabel = (manualRef(:,:,1)>.9*255) & ...
    (manualRef(:,:,2)<.1*255) & (manualRef(:,:,3)<.1*255);
reflabel = reflabel(1:size_record, 1:size_record);
if size(reflabel,1) > 768
    reflabel = imresize(reflabel, .5, 'nearest');
end

savepath = fullfile(alldatafolder, 'feature_n_label_storage', ...
    sprintf('%s %s %s labels.mat', pID, visit, refID));
save(savepath, 'reflabel');

