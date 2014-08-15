function labeled_img = find_normal( gabor_img, avg_img, anatomy_mask, debug )

%---Run pixelwise classification of normal retina-----
if debug == 1 || debug == 2
    disp('[NORM] Finding areas of normal retina');
end
%Load the classifier
model = load('normal_classifier.mat', 'scaling_factors','classifier');
scaling_factors = model.scaling_factors;
classifier = model.classifier;

%combine with other data from optic disk detection, and exclude vessel or
%od or normal pixels
feature_image = cat(3,gabor_img, avg_img);
instance_matrix = [];
for i = 1:size(feature_image,3)
    layer = feature_image(:,:,i);
    feature = layer(~anatomy_mask);
    instance_matrix = [instance_matrix, feature];
end

%Scale the vectors for input into the classifier
for i = 1:size(instance_matrix,2)
    fmin = scaling_factors(1,i);
    fmax = scaling_factors(2,i);
    instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
end

%Run hypo classification
labeled_img = zeros(size(anatomy_mask));
labeled_img(~anatomy_mask) = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
end

