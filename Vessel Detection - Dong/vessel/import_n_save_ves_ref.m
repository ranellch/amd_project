% close all
clear
clc

% alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-004';
visit = 'Baseline';
phase = 'early';
referencefolder = 'Manually Traced Vessels';
refpath = fullfile(alldatafolder, referencefolder, ...
    sprintf('vessels %s %s %s.png', pID, visit, phase) );

manualvessel = imread(refpath);
img_width = size(manualvessel, 2);
manualvessel = manualvessel(1:img_width, 1:end);
if size(manualvessel,1) > 768
    manualvessel = imresize(manualvessel, [768 768], 'nearest');
end

savepath = fullfile(alldatafolder, 'feature_n_label_storage', 'vessel', ...
    sprintf('%s %s %s vessel mask.mat', pID, visit, phase));
save(savepath, 'manualvessel');

