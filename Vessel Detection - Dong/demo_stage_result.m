% dual-phase registration and intensity enhancement highlights
% before 2014-04-25

% close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-005';
visit = 'Baseline';
datapath = fullfile(alldatafolder, pID, visit);
timings = xlsread(fullfile(datapath, 'timing')); 

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(3,:), datapath);
[img_early, ophth_acquis_context_early] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(1,:), datapath);

% [img_early, img_late] = normalizePixelSize(img_early, ophth_acquis_context_early, img_late, ophth_acquis_context_late);
if size(img_late, 1)>768
    img_late = imresize(img_late, .5);
end
if ~isequal(size(img_early), size(img_late))
    img_early = imresize(img_early, size(img_late));
end

% save for later in case needed
img_early_origin = img_early; 
img_late_origin = img_late;

% smoothing
f = fspecial('gaussian');
img_early = imfilter(img_early,f);
img_late = imfilter(img_late,f);

movingReg = phaseRegister(img_early, img_late);

% pathology segment
[DME_mask, enhancedImg] = unsupervisedLeakageThresholding(im2unitRange(img_late), movingReg);

imshow_sidebyside_origin_vs_filled(enhancedImg, DME_mask);
imshow_sidebyside_origin_vs_filled(img_late, DME_mask);

