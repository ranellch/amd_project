function [ hypo_img ] = find_hypo( pid, eye, time, varargin )
%Returns binary image indicating location of hypofluorescence
resize = 'on';
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

%Add the path for the useful directories
addpath('..');
addpath(genpath('../Test Set'));
addpath('../intensity normalization');
addpath('../snake');
addpath(genpath('../liblinear-3.18'))
addpath('../Skeleton');
addpath('../Vessel Detection - Chris');

%Load the classifier
model = load('hypo_classifier.mat', 'scaling_factors','classifier');
scaling_factors = model.scaling_factors;
classifier = model.pixel_classifier;

if debug == 1 || debug == 2
    disp('[HYPO] Finding areas of hypofluorescence');
end

original_img = imread(get_pathv2(pid, eye, time, 'original'));
original_img = imresize(original_img, [768 768]);

%Find optic disk and vessels
[od, vessels, angles, ~, gabor_img, avg_img, corrected_img] = find_od(pid, eye, time, debug, resize);

%Find fovea
[ x_fov,y_fov ] = find_fovea( vessels, angles, od, debug );

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
anatomy_mask = od || vessels;
instance_matrix = [];
for i = 1:std_size
    for j = 1:std_size
        if anatomy_mask(j,i) ~= 1
            current_vector = feature_image(j,i,:);
            instance_matrix = [instance_matrix; current_vector];
        end
    end
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
hypo_img = zeros(size(od));
[hypo_img(~anatomy_mask), ~, probabilities] = libsvmpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-b 1');
clear instance_matrix
probabilities 

prob_img = zeros(size(hypo_img));
prob_img(~anatomy_mask) = probabilities(:,2);

if(debug == 2)
    figure(11), imshow(display_mask(original_img, hypo_img, [1 0 0], 'solid'))
    figure(12), imshow(mat2gray(prob_img));
end

%final_segmentation = GraphCuts(logical(hypo_img), prob_img, cat(3,feature_image(:,:,1:size(gabor_img,3)),original_img));

% %---Run graph cuts using initial classification as seed points---
% %Calculate pairwise costs
% unary = zeros(2,numel(hypo_img));
% pairwise = spalloc(numel(hypo_img),numel(hypo_img),numel(hypo_img)*8);
% [H,W] = size(hypo_img);
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
% [LABELS ENERGY ENERGYAFTER] = GCMex(hypo_img(:), unary, pairwise,0)
% 


