close all
clear
clc

% alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-010';
visit = '6 month';
phase = 'early';
datapath = fullfile(alldatafolder, pID, visit);
timings = xlsread(fullfile(datapath, 'timing'));

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(3,:), datapath);
[img_peak, ophth_acquis_context_peak] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(2,:), datapath);
[img_early, ophth_acquis_context_early] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(1,:), datapath);

% [img_early, img_late] = normalizePixelSize(img_early, ophth_acquis_context_early, img_late, ophth_acquis_context_late);
if size(img_late, 1)>768
    img_late = imresize(img_late, .5);
end
if ~isequal(size(img_early), size(img_late))
    img_early = imresize(img_early, size(img_late));
end
if ~isequal(size(img_peak), size(img_late))
    img_peak = imresize(img_peak, size(img_late));
end

loadpath = fullfile(alldatafolder, 'feature_n_label_storage', 'vessel', ...
    sprintf('%s %s %s vessel mask.mat', pID, visit, phase));
load(loadpath);

eval(['img_cur = img_' phase ';']);
img = imoverlay(img_cur, manualvessel, [1 0 0]);
figure
subplot(1,2,1); imshow(img_cur);
subplot(1,2,2); imshow(img);
maximize

