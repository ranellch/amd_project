function [ final_segmentation ] = find_hyper( pid, eye, time, varargin )
%Returns binary image indicating location of hypofluorescence
resize = 'off';
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
elseif length(varargin) == 2
    debug = varargin{1};
    resize = varargin{2};
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arguments'));
end

t = cputime;
std_size = 768;

%Add the path for the useful directories
addpath('..');
addpath(genpath('../Test Set'));
addpath('../intensity normalization');
addpath('../snake');
addpath(genpath('../liblinear-3.18'))
addpath('../Skeleton');
addpath('../Vessel Detection - Chris');
addpath('../OD Detection - Chris');
addpath('../Fovea Detection - Chris');
addpath('../Graph Cuts');

%Load the classifier
model = load('hyper_classifier.mat', 'scaling_factors','classifier');
scaling_factors = model.scaling_factors;
classifier = model.classifier;

if debug == 1 || debug == 2
    disp('[HYPER] Finding areas of hyperfluorescence');
end

original_img = imread(get_pathv2(pid, eye, time, 'original'));
if size(original_img,3) > 1
    original_img = rgb2gray(original_img);
end
original_img = imresize(original_img, [std_size std_size]);
original_img = im2double(original_img);

%Find optic disk and vessels
[od, vessels, angles, ~, gabor_img, avg_img, corrected_img] = find_od(pid, eye, time, debug, resize);

%Find fovea
[ x_fov,y_fov ] = find_fovea( vessels, angles, od, 1 );

%Show the user what's been detected so far
if debug == 2
    combined_img = display_anatomy( original_img, od, vessels, x_fov, y_fov );
    figure(10), imshow(combined_img)
end

%---Run pixelwise classification of hypofluorescence-----
%Get radial coords
coord_system = get_radial_coords(size(od),x_fov,y_fov);
%combine with other data from optic disk detection, and exclude vessel or
%od pixels
feature_image = cat(3,gabor_img, avg_img, coord_system);
anatomy_mask = od | vessels;
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

%Run the classification algorithm
if(debug == 1 || debug == 2)
    disp('[SVM] Running the classification algorithm');
end
labeled_img = zeros(size(od));
[labeled_img(~anatomy_mask), ~, probabilities] = libsvmpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q -b 1');
clear instance_matrix

prob_img = zeros(size(labeled_img));
prob_img(~anatomy_mask) = probabilities(:,2);

final_segmentation = GraphCutsHypo(logical(labeled_img), prob_img, cat(3,feature_image(:,:,1:size(gabor_img,3)),corrected_img));

if(debug == 2)
    figure(11), imshow(display_outline(original_img, logical(labeled_img), [1 1 0]))
    figure(12), imshow(prob_img);
    figure(13), imshow(display_outline(original_img, logical(final_segmentation), [1 1 0]));
end

e = cputime - t;
disp(['Total [HYPER] Processing Time (min): ', num2str(e/60.0)]);

% %---Run graph cuts using initial classification as seed points---
% %Calculate pairwise costs
% unary = zeros(2,numel(labeled_img));
% pairwise = spalloc(numel(labeled_img),numel(labeled_img),numel(labeled_img)*8);
% [H,W] = size(labeled_img);
% for col = 1:W
%   for row = 1:H
%     pixel = (col-1)*H + row;
%     if row+1 <= H, pairwise(pixel, (col-1)*H+row+1) = 1; 
%         if col+1 
%     if row-1 > 0, pairwise(pixel, (col-1)*H+row-1) = 1; end 
%     if col+1 <= W, pairwise(pixel, col*H+row) = 1; end
%     if col-1 > 0, pairwise(pixel, (col-2)*H+row) = 1; end 
%     unary(:,pixel) = [1-prob_img(row,col), prob_img(row,col)]';  
%   end
% end
% [LABELS ENERGY ENERGYAFTER] = GCMex(labeled_img(:), unary, pairwise,0)
% 


