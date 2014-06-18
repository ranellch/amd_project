% close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-001';
visit = 'Baseline';
phase = 'peak';
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

% save for later in case needed
img_early_origin = img_early; 
img_peak_origin = img_peak; 
img_late_origin = img_late;

% noise removal
f = fspecial('gaussian');
img_early = imfilter(img_early,f);
img_peak = imfilter(img_peak,f);
img_late = imfilter(img_late,f);

eval(['img_cur = img_' phase ';']);
vessel_features = zero_m_unit_std(img_cur);
for o = 2:4
    for l = [9 11]
        vesselResponse = matchingfiltering(img_cur, 15, o, l);
        vessel_features = cat(3, vessel_features, zero_m_unit_std(vesselResponse));
    end
end

savepath = fullfile(alldatafolder, 'feature_n_label_storage', 'vessel', ...
    sprintf('%s %s %s vessel features.mat', pID, visit, phase));
save(savepath, 'vessel_features');

