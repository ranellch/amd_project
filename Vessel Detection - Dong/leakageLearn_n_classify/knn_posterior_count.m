% close all
clear
clc

% alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-005';
visit = 'Baseline';
refID = 'Dr.J';
datapath = fullfile(alldatafolder, pID, visit);
timings = xlsread(fullfile(datapath, 'timing'));

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(3,:), datapath);
[img_early, ophth_acquis_context_early] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(1,:), datapath);

if size(img_late, 1)>768
    img_late = imresize(img_late, .5);
end
if ~isequal(size(img_early), size(img_late))
    img_early = imresize(img_early, size(img_late));
end

img_late_origin = img_late; % save for later in case needed
img_late = imhistmatch(img_late, img_early);
img_late = im2unitRange(img_late);

feature_n_label_folder = fullfile(alldatafolder, 'feature_n_label_storage');
targetFeatureFile = sprintf('%s %s features.mat', pID, visit);
load(fullfile(feature_n_label_folder, targetFeatureFile));
targetFeature = extractValidFeatureVectorsInRows(features, validityMask);
targetValidityMask = validityMask;

% load training features & labels
list_of_features = dir(fullfile(feature_n_label_folder, '*features*'));
num_of_samples = length(list_of_features);
trainingFeatures = [];
trainingLabels = false(0);
for i = 1:num_of_samples
    featurefile = list_of_features(i).name;
    if isequal(featurefile, targetFeatureFile)
        continue
    end
    load( fullfile(feature_n_label_folder,featurefile) );
    trainingFeatures = [trainingFeatures; ...
        extractValidFeatureVectorsInRows(features, validityMask)];
    
    labelfile = strrep(featurefile, 'features', [refID ' labels']);
    load(fullfile(feature_n_label_folder, labelfile));
    trainingLabels = [trainingLabels; ...
        extractValidFeatureVectorsInRows(reflabel, validityMask)];
end

selectedIdx = randperm(numel(trainingLabels), 768^2);
selectedTrainingLabels = trainingLabels(selectedIdx);
num_of_nn = 10;
NPind = knnsearch(trainingFeatures(selectedIdx,:), targetFeature, 'K', num_of_nn);
positive_posterior = zeros(size(NPind,1), 1);
for i = 1:size(NPind,1)
    knn_count = sum( selectedTrainingLabels(NPind(i,:)) );
    positive_posterior(i) = knn_count/num_of_nn;
end

positive_posterior_map = zeros(size(targetValidityMask));
positive_posterior_map(targetValidityMask) = positive_posterior;
figure
imshowpair(img_late, positive_posterior_map, 'falsecolor')

optimizedLabeling = prepare_n_cut(img_late, positive_posterior_map, 100);
optimizedLabeling = bwmorph(optimizedLabeling, 'clean');
optimizedLabeling = bwmorph(optimizedLabeling, 'fill');
img = imoverlay(img_late, optimizedLabeling, [1 0 0]);
figure
subplot(1,2,1), imshow(img_late)
subplot(1,2,2), imshow(img)
maximize

