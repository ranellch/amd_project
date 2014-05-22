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
img_early = imfilter(img_early,f);
img_peak = imfilter(img_peak,f);
img_late = imfilter(img_late,f);

% early phase
vessel_early = vesselDetect(img_early, 'matching');
imshow_sidebyside_origin_vs_filled(img_early, vessel_early);
img_norm = FA_illum_norm_4vessel_detection(img_early, vessel_early);
vessel_early = vessel_early | vesselDetect(img_norm, 'matching');
% imshow_sidebyside_origin_vs_filled(img_early, vessel_early);
vessel_early = bwmorph(vessel_early, 'bridge');
vessel_early = vesselCCFilterRemoveRoundBlobs(vessel_early, .5);
imshow_sidebyside_origin_vs_filled(img_early, vessel_early);

% peak phase
vessel_peak = vesselDetect(img_peak, 'matching');
imshow_sidebyside_origin_vs_filled(img_peak, vessel_peak);
[img_norm, nonvasmask] = FA_illum_norm_4vessel_detection(img_peak, vessel_peak, true);
vessel_peak = vessel_peak | vesselDetect(img_norm, 'matching');
imshow_sidebyside_origin_vs_filled(img_peak, vessel_peak);
vessel_peak = bwmorph(vessel_peak, 'hbreak');
vessel_peak = vesselCCFilterRemoveRoundBlobs(vessel_peak, .5);
imshow_sidebyside_origin_vs_filled(img_peak, vessel_peak);
% tformEarlyPeak = imregcorr(img_early, img_peak);
% Rfixed = imref2d(size(img_peak));
% marker = imwarp(vessel_early, tformEarlyPeak, 'OutputView', Rfixed, ...
%     'FillValues', 0);
% vessel_peak = imreconstruct(marker, vessel_peak);
% imshow_sidebyside_origin_vs_filled(img_peak, vessel_peak);

% late phase
tformEarlyLate = imregcorr(img_early,img_late);
tformPeakLate = imregcorr(img_peak,img_late);
Rfixed = imref2d(size(img_late));
vessel_late_marker1 = imwarp(vessel_early, tformEarlyLate, 'OutputView', Rfixed, ...
    'FillValues', 0);
vessel_late_marker2 = imwarp(vessel_peak, tformPeakLate, 'OutputView', Rfixed, ...
    'FillValues', 0);
vessel_late_marker = vessel_late_marker1 | vessel_late_marker2;
imshow_sidebyside_origin_vs_filled(img_late, vessel_late_marker);
vessel_late_marker = bwmorph(vessel_late_marker, 'hbreak');
vessel_late_marker = vesselCCFilterKeepLargestN(vessel_late_marker,6);
vessel_late_marker = CCFilterRemoveSmallBlobs(vessel_late_marker, 128);
vessel_late_marker = vesselCCFilterRemoveRoundBlobs(vessel_late_marker, .5);
imshow_sidebyside_origin_vs_filled(img_late, vessel_late_marker);
vessel_late = vessel_late_marker;
% % late phase vessel self detection + reconstruction
% vessel_late = vesselDetect(img_late, 'matching');
% imshow_sidebyside_origin_vs_filled(img_late, vessel_late);
% vessel_late = bwmorph(vessel_late, 'hbreak');
% vessel_late = vesselCCFilterKeepLargestN(vessel_late,6);
% vessel_late = CCFilterRemoveSmallBlobs(vessel_late, 128);
% vessel_late = vesselCCFilterRemoveRoundBlobs(vessel_late, .5);
% imshow_sidebyside_origin_vs_filled(img_late, vessel_late);
% vessel_late = imreconstruct(vessel_late_marker, vessel_late);
% imshow_sidebyside_origin_vs_filled(img_late, vessel_late);

