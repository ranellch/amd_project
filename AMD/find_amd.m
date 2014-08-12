function [ final_hypo, final_hyper, scores ] = find_amd( pid, eye, time, varargin )
%Returns binary image indicating location of hypofluorescence
resize = 'off';
status = 'generate'; 
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
elseif length(varargin) == 2
    debug = varargin{1};
    resize = varargin{2};
elseif length(varargin) == 3
    debug = varargin{1};
    resize = varargin{2};
    status = varargin{3};
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
addpath(genpath('../libsvm-3.18'))
addpath(genpath('../liblinear-1.94'))
addpath('../Skeleton');
addpath('../Vessel Detection - Chris');
addpath('../OD Detection - Chris');
addpath('../Fovea Detection - Chris');
addpath('../Graph Cuts');
addpath('../superpixels');

original_img = imread(get_pathv2(pid, eye, time, 'original'));
if size(original_img,3) > 1
    original_img = rgb2gray(original_img);
end
original_img = imresize(original_img, [std_size std_size]);
original_img = im2double(original_img);

%Get intermediate data either by generating it or loading from file
file = ['./matfiles/',pid,'_',eye,'_',time,'.mat'];

if strcmp(status,'generate')
    %Find optic disk and vessels
    [od, vessels, angles, ~, gabor_img, avg_img, corrected_img] = find_od(pid, eye, time, debug, resize);

    %Find fovea
	if ~any(od(:))
        [x_fov,y_fov] = find_fovea_no_od(vessels,angles,1);
	else
		[ x_fov,y_fov ] = find_fovea( vessels, angles, od, 1 );
	end
    
    if ~isdir('./matfiles')
        mkdir('./matfiles');
    end

    save(file,'od','vessels','gabor_img','avg_img','corrected_img','x_fov','y_fov');
else
    int_data = load(file);
    od = int_data.od;
    vessels = int_data.vessels;
    gabor_img = int_data.gabor_img;
    avg_img = int_data.avg_img;
    corrected_img = int_data.corrected_img;
    x_fov = int_data.x_fov;
    y_fov = int_data.y_fov;
end

%Show the user what's been detected so far
if debug == 2
    combined_img = display_anatomy( original_img, od, vessels, x_fov, y_fov );
    figure(10), imshow(combined_img)
end

%---Run pixelwise classification of hypofluorescence-----
if debug == 1 || debug == 2
    disp('[HYPO] Finding areas of hypofluorescence');
end
%Load the classifier
model = load('hypo_classifier.mat', 'scaling_factors','classifier');
scaling_factors = model.scaling_factors;
classifier = model.classifier;

% %Get radial coords
 dist = get_radial_dist(size(od),x_fov,y_fov);

%combine with other data from optic disk detection, and exclude vessel or
%od pixels
figure, imshow(mat2gray(avg_img))
figure, imshow(mat2gray(corrected_img))
return
feature_image = cat(3,gabor_img, avg_img, dist);
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

%Run hypo classification
labeled_img = zeros(size(od));
[labeled_img(~anatomy_mask), ~, probabilities] = libsvmpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q -b 1');
clear instance_matrix

prob_img = zeros(size(labeled_img));
prob_img(~anatomy_mask) = probabilities(:,classifier.Label==1);
figure, imshow(prob_img)
hold on
plot(x_fov,y_fov,'go')
hold off

final_hypo = GraphCutsHypo(logical(labeled_img), prob_img, cat(3,feature_image(:,:,1:size(gabor_img,3)),corrected_img));

if(debug == 2)
    figure(11), imshow(display_outline(original_img, logical(labeled_img), [1 0 0]))
    figure(12), imshow(prob_img);
    figure(13), imshow(display_outline(original_img, logical(final_hypo), [1 0 0]));
end

if any(final_hypo(:))
    hypo_input = final_hypo;
else
    hypo_input = [x_fov,y_fov];
end

%-----Run superpixelwise classification of hyperfluorescence-----
if debug == 1 || debug == 2
    disp('[HYPER] Finding areas of hyperfluorescence');
end

%get superpixels from intensity image
norm_img = zero_m_unit_std(corrected_img);
im = cat(3,norm_img, norm_img, norm_img);
k = 1000;
m = 20;
seRadius = 1;
threshold = 4;
[l, Am, Sp, ~] = slic(im, k, m, seRadius);
%cluster superpixels
lc = spdbscan(l, Sp, Am, threshold);
%generate feature vectors for each labeled region
[~, Al] = regionadjacency(lc);
instance_matrix = get_fv_hyper(lc,Al,hypo_input,norm_img);

%Load the classifier
model = load('hyper_classifier.mat', 'scaling_factors','classifier');
scaling_factors = model.scaling_factors;
classifier = model.classifier;

%Scale the vectors for input into the classifier
for i = 1:size(instance_matrix,2)
    fmin = scaling_factors(1,i);
    fmax = scaling_factors(2,i);
    instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
end

classifications = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
clear instance_matrix

final_hyper = zeros(size(corrected_img));
for i = 1:length(classifications)
    final_hyper(lc==i) = classifications(i);
end

final_hyper = logical(final_hyper);

if(debug == 2)
    figure(14), imshow(display_outline(original_img, final_hyper, [1 1 0]));
end

%Generate quantification metrics
corrected_img = mat2gray(corrected_img);
scores = struct;
%1 pixel = 2.5e-5 mm^2
scores.hypo_area = sum(final_hypo(:))*2.5e-5;
scores.hypo_intensity = mean(corrected_img(final_hypo));
scores.hypo_score = (1-scores.hypo_intensity)*scores.hypo_area;
scores.hyper_area = sum(final_hyper(:))*2.5e-5;
scores.hyper_intensity = mean(corrected_img(final_hyper));
scores.hyper_score = scores.hyper_intensity*scores.hyper_area;
scores.combined_score = scores.hypo_score+scores.hyper_score;

e = cputime - t;
disp(['Total [AMD] Processing Time (min): ', num2str(e/60.0)]);



