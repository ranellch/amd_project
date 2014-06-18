% close all
clear
clc

% datapath = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data\JDRF-004\6 month';
datapath = 'D:\Dropbox\Eye Image Analysis\DME project\data\JDRF-004\6 month';
timings = xlsread(fullfile(datapath, 'timing')); 

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(3,:), datapath);

[img_early, ophth_acquis_context_early] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(2,:), datapath);

% [img_early, img_late] = normalizePixelSize(img_early, ophth_acquis_context_early, img_late, ophth_acquis_context_late);
if ~isequal(size(img_early), size(img_late))
    img_early = imresize(img_early, size(img_late));
end

img_early = imresize(img_early, .25);
img_late = imresize(img_late, .25);

manualRigidRegister;

