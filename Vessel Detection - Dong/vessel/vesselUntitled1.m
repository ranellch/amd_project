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
early_features = vesselFeatures(img_early, 'matching');
tformEarlyLate = imregcorr(img_early,img_late);
Rfixed = imref2d(size(img_late));
for i = 1:size(early_features, 3)
    early_features(:,:,i) = imwarp(early_features(:,:,i), tformEarlyLate, 'OutputView', Rfixed, ...
        'FillValues', NaN);
end

% peak phase
peak_features = vesselFeatures(img_peak, 'matching');
tformPeakLate = imregcorr(img_peak,img_late);
for i = 1:size(peak_features, 3)
    peak_features(:,:,i) = imwarp(peak_features(:,:,i), tformPeakLate, 'OutputView', Rfixed, ...
        'FillValues', NaN);
end

validityMask = ~( isnan(early_features(:,:,1)) | isnan(peak_features(:,:,1)) );

% late phase
late_features = vesselFeatures(img_late, 'matching');

vessel_features = cat(3, early_features, peak_features, late_features);
label = litekmeans(...
    extractValidFeatureVectorsInRows(vessel_features, validityMask).', 2);
if sum(label==2)*2<numel(label)
    label = label==2;
else
    label = label==1;
end
vesselmap123 = false(size(img_late));
vesselmap123(validityMask) = label;
imshow_sidebyside_origin_vs_filled(img_late, vesselmap123);

vessel_features = cat(3, early_features, peak_features);
label = litekmeans(...
    extractValidFeatureVectorsInRows(vessel_features, validityMask).', 2);
if sum(label==2)*2<numel(label)
    label = label==2;
else
    label = label==1;
end
vesselmap12 = false(size(img_late));
vesselmap12(validityMask) = label;
imshow_sidebyside_origin_vs_filled(img_late, vesselmap12);

vessel_features = cat(3, peak_features, late_features);
label = litekmeans(...
    extractValidFeatureVectorsInRows(vessel_features, validityMask).', 2);
if sum(label==2)*2<numel(label)
    label = label==2;
else
    label = label==1;
end
vesselmap23 = false(size(img_late));
vesselmap23(validityMask) = label;
imshow_sidebyside_origin_vs_filled(img_late, vesselmap23);

vessel_features = cat(3, early_features, late_features);
label = litekmeans(...
    extractValidFeatureVectorsInRows(vessel_features, validityMask).', 2);
if sum(label==2)*2<numel(label)
    label = label==2;
else
    label = label==1;
end
vesselmap13 = false(size(img_late));
vesselmap13(validityMask) = label;
imshow_sidebyside_origin_vs_filled(img_late, vesselmap13);

