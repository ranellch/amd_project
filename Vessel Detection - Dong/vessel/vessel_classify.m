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

feature_n_label_folder = fullfile(alldatafolder, 'feature_n_label_storage', 'vessel');
targetFeatureFile = sprintf('%s %s %s vessel features.mat', pID, visit, phase);
load(fullfile(feature_n_label_folder, targetFeatureFile));
targetFeature = reorganizeLayeredImgFeatures2RowFeatureVectors(vessel_features);

% load training features & labels
list_of_labelfiles = dir( fullfile(feature_n_label_folder, '*mask*') );
%sprintf('*%s*mask*',phase)) );
num_of_labelfiles = length(list_of_labelfiles);
trainingFeatures = [];
trainingLabels = false(0);
for i = 1:num_of_labelfiles
    labelfile = list_of_labelfiles(i).name;
    featurefile = strrep(labelfile, 'mask', 'features');
    if isequal(featurefile, targetFeatureFile)
        continue
    end
    
    load( fullfile(feature_n_label_folder,featurefile) );
    trainingFeatures = [trainingFeatures; ...
        reorganizeLayeredImgFeatures2RowFeatureVectors(vessel_features)];
    
    load(fullfile(feature_n_label_folder, labelfile));
    trainingLabels = [trainingLabels; manualvessel(:)];
end

num_of_training_points = 20000;

posSampleIdx = find(trainingLabels);
negSampleIdx = find(~trainingLabels);
selectedPosIdx = randperm(numel(posSampleIdx), num_of_training_points/2);
selectedNegIdx = randperm(numel(negSampleIdx), num_of_training_points/2);
selectedIdx = [posSampleIdx(selectedPosIdx); negSampleIdx(selectedNegIdx)];

% selectedIdx = randperm(numel(trainingLabels), num_of_training_points);

SVMStruct = svmtrain(trainingFeatures(selectedIdx,:),trainingLabels(selectedIdx));
class = svmclassify(SVMStruct, targetFeature);

% class = knnclassify(targetFeature, ...
%     trainingFeatures(selectedIdx,:), trainingLabels(selectedIdx), 5);

vesselmap = reshape(class, 768, []);
vesselmap = bwmorph(vesselmap, 'clean');
vesselmap = bwmorph(vesselmap, 'fill');
eval(['img_cur = img_' phase ';']);
img = imoverlay(img_cur, vesselmap, [1 0 0]);
figure
subplot(1,2,1), imshow(img_cur)
subplot(1,2,2), imshow(img)
maximize

