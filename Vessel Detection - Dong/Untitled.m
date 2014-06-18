% close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-002';
visit = '6 month';
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
img_early = imfilter(img_early, f);
img_peak = imfilter(img_peak, f);
img_late = imfilter(img_late, f);

%% image registration
[~, tformEstimate, Rfixed] = phaseRegister(img_early, img_late);

%% illumination normalization
[img_early_norm, manualmask] = FA_illum_norm(img_early);
manualmask = imwarp(manualmask, tformEstimate, 'OutputView', Rfixed, ...
    'FillValues', 0);
img_late_norm = FA_illum_norm(img_late, manualmask);

%% transform early to late phase
movingReg = imwarp(img_early_norm, tformEstimate, 'OutputView', Rfixed, ...
    'FillValues', max(img_early_norm(:)));
movingReg = im2unitRange(movingReg);

%% pathology segment
[DME_mask, enhancedImg] = unsupervisedLeakageThresholding(img_late_norm, movingReg);

imshow_sidebyside_origin_vs_filled(enhancedImg, DME_mask);
imshow_sidebyside_origin_vs_filled(img_late, DME_mask);

