close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-001';
visit = 'Baseline';
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

% register early/peak to late phase
tformEarly = imregcorr(img_early,img_late);
tformPeak = imregcorr(img_peak,img_late);

% % smoothing
% f = fspecial('average', 5);
% img_early = imfilter(img_early, f);
% img_peak = imfilter(img_peak, f);
% img_late = imfilter(img_late, f);

% transform early/peak to late phase
Rfixed = imref2d(size(img_late));
earlyReg = imwarp(img_early, tformEarly, 'OutputView', Rfixed, ...
    'FillValues', NaN);
peakReg = imwarp(img_peak, tformPeak, 'OutputView', Rfixed, ...
    'FillValues', NaN);

validityMask = ~( isnan(earlyReg) | isnan(peakReg) );

% features: 
% (normalized) image intensity
img_late = zero_m_unit_std(img_late);
earlyReg = zero_m_unit_std(earlyReg);
peakReg = zero_m_unit_std(peakReg);

% intensity change cross phases
diffPeakEarly = peakReg - earlyReg;
diffPeakEarly = zero_m_unit_std(diffPeakEarly);

diffLateEarly = img_late - earlyReg;
diffLateEarly = zero_m_unit_std(diffLateEarly);
% diffEarly(diffEarly<0) = 0;
% diffEarly = im2unitRange(diffEarly);

diffLatePeak = img_late - peakReg;
diffLatePeak = zero_m_unit_std(diffLatePeak);
% diffPeak(diffPeak<0) = 0;
% diffPeak = im2unitRange(diffPeak);

% warning('off', 'images:initSize:adjustingMag');
% figure
% imshow(diffEarly);
% maximize
% figure
% imshow(diffPeak);
% maximize
% warning('on', 'images:initSize:adjustingMag');

features = cat(3, earlyReg, peakReg, img_late, ...
    diffPeakEarly, diffLateEarly, diffLatePeak);

savepath = fullfile(alldatafolder, 'feature_n_label_storage', ...
    'leakage', sprintf('%s %s features.mat', pID, visit));
save(savepath, 'features', 'validityMask');

