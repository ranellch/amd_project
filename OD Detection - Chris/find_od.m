function [final_od_image, img_vessel, img_angles, probability] = find_od(pid, eye, time, varargin)
debug = -1;
resize = 'on';
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
elseif length(varargin) == 2
    debug = varargin{1};
    resize = varargin{2};
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
end

%Standardize variables
t = cputime;

%Add the path for the useful directories
addpath('..');
addpath(genpath('../Test Set'));
addpath('../intensity normalization');
addpath('../snake');
addpath(genpath('../liblinear-1.94'))
addpath('../Skeleton');
addpath('../Vessel Detection - Chris');
        
%Load the prediction structs
model = load('od_classifiers.mat', 'scaling_factors','pixel_classifier');
scaling_factors = model.scaling_factors;
classifier = model.pixel_classifier;

%Print to the console the output
if(debug == 1 || debug == 0)
    disp(['[ID] ', pid, ' - Time: ', num2str(time)]);
end

%Get the vesselized image for now (need to change to find_vessels at some time)
if(debug == 1 || debug == 2)
    disp('[VESSELS] Run Vessel Detection Algorithm');
end
[img_vessel, img_angles, corrected_img] = find_vessels(pid,eye,time,debug);

%Get the dimensions of the original image
orig_img = imread(get_pathv2(pid,eye,time,'original'));
orig_img = crop_footer(orig_img);
origy = size(orig_img, 1);
origx = size(orig_img, 2);

%Normalize intensities
norm_img = zero_m_unit_std(corrected_img);

%Initiate the results image
od_image = zeros(size(norm_img, 1), size(norm_img, 2));

%Get feature vectors for each pixel in image
if(debug == 1 || debug == 2)
    disp('[FV] Building the pixelwise feature vectors');
end
feature_image_g = get_fv_gabor_od(norm_img);
feature_image_r = imfilter(norm_img,ones(3)/9, 'symmetric');

%Build the finalized feature vector
feature_image = zeros(size(od_image,1), size(od_image,2), size(feature_image_g,3) + size(feature_image_r,3));

for y=1:size(feature_image, 1)
    for x=1:size(feature_image, 2)
        temp = 1;
        for z1=1:size(feature_image_g,3)
            feature_image(y,x,temp) = feature_image_g(y,x,z1);
            temp = temp + 1;
        end
        for z2=1:size(feature_image_r,3)
            feature_image(y,x,temp) = feature_image_r(y,x,z2);
            temp = temp + 1;
        end
    end
end

%convert this feature image into a flat array of feature vectors
instance_matrix = matstack2array(feature_image);

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
od_image(:) = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
clear instance_matrix

if(debug == 2)
    figure(1), imshow(od_image);
end

%Remove all classified datapoints that were already classified as a vessel
positive_count = 0;
img_vessels_negatve = bwmorph(img_vessel, 'thicken', 5);
for y=1:size(od_image)
    for x=1:size(od_image)
        if(img_vessels_negatve(y,x) == 1)
            od_image(y,x) = 0;
        end
        if(od_image(y,x) == 1)
            positive_count = positive_count + 1;
        end
    end
end

%Cluster the datapoints into regions using agglomerative clustering
if(debug == 1 || debug == 2)
    disp(['[CLUSTERING] Running the clustering algorithm (', num2str(positive_count), ')']);
end

%Run the clustering algorithm if there are regions to cluster
if(positive_count > 10)
    final_clusters = cluster_texture_regions(od_image, debug);
else
    final_od_image = od_image;
    return;
end

if(debug == 2)
    figure(2), imagesc(final_clusters);
end

% %Translate the cluster mask to the od_image
% for y=1:size(final_clusters_mask,1)
%     for x=1:size(final_clusters_mask,2)
%         if (final_clusters_mask(y,x) > 0)
%             od_image(y,x) = 1;
%         else
%             od_image(y,x) = 0;
%         end
%     end
% end
% 
% if(debug == 2)
%     figure(4), imshowpair(od_image, img_vessel);
% end

%Find optic disk region using another classifier
[pre_snaked_img, probability] = choose_od(final_clusters, img_vessel, img_angles, debug);
if ~any(pre_snaked_img(:))
    final_od_image = imresize(pre_snaked_img,[origy,origx]);
    disp('Optic Disk Not Found!')
    return
end
if (debug == 2)
    figure(4), imshowpair(pre_snaked_img,img_vessel)
end

%Use snaking algorithm to get smooth outline of the optic disc
if(debug == 1 || debug == 2)
    disp('[SNAKES] Using Snaking algorithm to refine the edges of the optic disc');
end

Options=struct;
% if debug == 2
%     Options.Verbose=true;
% else 
    Options.Verbose=false;
% end
Options.Iterations=100;
Options.Wedge=30;
Options.Wline = .6;
Options.Wterm = 20;
Options.Alpha = 5;
Options.Beta = 2;
Options.Delta = 3.5;
Points = get_box_coordinates(pre_snaked_img);
pre_snaked_img = mat2gray(corrected_img);
pre_snaked_img(img_vessel) = 1;
[~,snaked_optic_disc] = Snake2D(pre_snaked_img, Points, Options); 

if(debug == 2)
    %Show the image result
    figure(5), imshowpair(snaked_optic_disc, corrected_img);
end

%Resize the image to its original size
if strcmp(resize,'on')
    snaked_optic_disc = imresize(snaked_optic_disc, [origy origx]);
end
    
%return the final image to the function caller
final_od_image = snaked_optic_disc;

%Report the time it took to classify to the user
e = cputime - t;
if(debug == 1 || debug ==2)
    disp(['[TIME] Optic Disc Classification Time (min): ', num2str(e/60.0)]);
end

end
