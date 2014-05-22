% close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-002';
visit = '6 month';
refID = 'Dr.J';
datapath = fullfile(alldatafolder, pID, visit);
timings = xlsread(fullfile(datapath, 'timing'));

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(3,:), datapath);
[img_peak, ophth_acquis_context_peak] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(2,:), datapath);
[img_early, ophth_acquis_context_early] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(1,:), datapath);

if size(img_late, 1)>768
    img_late = imresize(img_late, .5);
end

feature_n_label_folder = fullfile(alldatafolder, 'feature_n_label_storage', 'leakage');
targetFeatureFile = sprintf('%s %s features.mat', pID, visit);
load(fullfile(feature_n_label_folder, targetFeatureFile));
targetFeature = extractValidFeatureVectorsInRows(features, validityMask);
targetValidityMask = validityMask;

% load training features & labels
list_of_labelfiles = dir(fullfile(feature_n_label_folder, ['*' refID ' labels*']));
num_of_labelfiles = length(list_of_labelfiles);
trainingFeatures = [];
trainingLabels = false(0);
for i = 1:num_of_labelfiles
    labelfile = list_of_labelfiles(i).name;
    featurefile = strrep(labelfile, [refID ' labels'], 'features');
    if isequal(featurefile, targetFeatureFile)
        continue
    end
    
    load( fullfile(feature_n_label_folder,featurefile) );
    trainingFeatures = [trainingFeatures; ...
        extractValidFeatureVectorsInRows(features, validityMask)];
    
    load(fullfile(feature_n_label_folder, labelfile));
    trainingLabels = [trainingLabels; ...
        extractValidFeatureVectorsInRows(reflabel, validityMask)];
end

num_of_training_points = 10000;
posSampleIdx = find(trainingLabels);
negSampleIdx = find(~trainingLabels);
selectedPosIdx = randperm(numel(posSampleIdx), num_of_training_points/2);
selectedNegIdx = randperm(numel(negSampleIdx), num_of_training_points/2);
selectedIdx = [posSampleIdx(selectedPosIdx); negSampleIdx(selectedNegIdx)];

% selectedIdx = randperm(numel(trainingLabels), 768^2);

% class = knnclassify(targetFeature, ...
%     trainingFeatures(selectedIdx,:), trainingLabels(selectedIdx), 5);

SVMStruct = svmtrain(trainingFeatures(selectedIdx,:),trainingLabels(selectedIdx), ...
    'options', statset('MaxIter', 60000));
class = svmclassify(SVMStruct, targetFeature);

classmap = false(size(targetValidityMask));
classmap(targetValidityMask) = class;
% classmap = reshape(class, 768, []);
classmap = bwmorph(classmap, 'clean');
classmap = bwmorph(classmap, 'fill');

%%


%% display

img = imoverlay(img_late, classmap, [1 0 0]);
figure
subplot(1,2,1), imshow(img_late)
subplot(1,2,2), imshow(img)
maximize

