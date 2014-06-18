% close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-006';
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

%% phase registration
tformEarlyLate = imregcorr(img_early,img_late);
tformPeakLate = imregcorr(img_peak,img_late);
tformEarlyPeak = imregcorr(img_early, img_peak);

%% illumination normalization
[img_early_norm, manualmask_early, vessel_early] = FA_illum_norm(img_early);
Rfixed = imref2d(size(img_peak));
manualmask_early2peak = imwarp(manualmask_early, tformEarlyPeak, 'OutputView', Rfixed, ...
    'FillValues', 0);
[img_peak_norm, ~, vessel_peak] = FA_illum_norm(img_peak, manualmask_early2peak);
Rfixed = imref2d(size(img_late));
manualmask_early2late = imwarp(manualmask_early, tformEarlyLate, 'OutputView', Rfixed, ...
    'FillValues', 0);
[img_late_norm, ~, vessel_late] = FA_illum_norm(img_late, manualmask_early2late);

%% transform early/peak to late phase
earlyReg = imwarp(img_early_norm, tformEarlyLate, 'OutputView', Rfixed, ...
    'FillValues', NaN);
vessel_early = imwarp(vessel_early, tformEarlyLate, 'OutputView', Rfixed, ...
    'FillValues', 0);
peakReg = imwarp(img_peak_norm, tformPeakLate, 'OutputView', Rfixed, ...
    'FillValues', NaN);
vessel_peak = imwarp(vessel_peak, tformPeakLate, 'OutputView', Rfixed, ...
    'FillValues', 0);

validityMask = ~( isnan(earlyReg) | isnan(peakReg) );

%% features: 
% (normalized) image intensity
img_late_norm = zero_m_unit_std(img_late_norm);
earlyReg = zero_m_unit_std(earlyReg);
peakReg = zero_m_unit_std(peakReg);

% intensity change cross phases
diffPeakEarly = peakReg - earlyReg;
diffPeakEarly = zero_m_unit_std(diffPeakEarly);

diffLateEarly = img_late_norm - earlyReg;
diffLateEarly = zero_m_unit_std(diffLateEarly);
% diffEarly(diffEarly<0) = 0;
% diffEarly = im2unitRange(diffEarly);

diffLatePeak = img_late_norm - peakReg;
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

features = cat(3, earlyReg, peakReg, img_late_norm, ...
    diffPeakEarly, diffLateEarly, diffLatePeak, ...
    vessel_early, vessel_peak, vessel_late);

savepath = fullfile(alldatafolder, 'feature_n_label_storage', ...
    'leakage', sprintf('%s %s features.mat', pID, visit));
save(savepath, 'features', 'validityMask');

