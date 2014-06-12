function [final_od_image, img_vessel] = find_od(pid, eye, time)

%Standardize variables
std_img_size = 768;
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
model = load('od_classify_svmstruct.mat');
scaling_factors = model.scaling_factors;
classifier = model.od_classify_svmstruct;

%Get the path name from the image and time and then read in the image.
filename = get_pathv2((pid), (eye), num2str(time), 'original');
img = imread(filename);

%Convert the image to gray scale double if not already
img = im2double(img);
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

%Get the vesselized image for now (need to change to find_vessels at some time)
disp('[VESSELS] Run Vessel Detection Algorithm');
[img_vessel, img_angles] = find_vessels(pid,eye,time);

%Get the longest dimension of the original image
origy = size(img, 1);
origx = size(img, 2);

%Resize the images to a standard size
img = imresize(img, [std_img_size, std_img_size]);
img_vessel = imresize(img_vessel,[std_img_size, std_img_size]);

%Apply a gaussian filter to the image and the smooth out the illumination
img = gaussian_filter(img);
[img, ~] = smooth_illum3(img, 0.7);

%Print to the console the output
disp(['[ID] ', pid, ' - Time: ', num2str(time)]);

%Initiate the results image
od_image = zeros(size(img, 1), size(img, 2));

%Get feature vectors for each pixel in image
disp('[FV] Building the pixelwise feature vectors');
feature_image_g = get_fv_gabor(img);
feature_image_r = rangefilt(img);

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
disp('[SVM] Running the classification algorithm');
od_image(:) = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
clear instance_matrix

%Remove all classified datapoints that were already classified as a vessel
for y=1:size(od_image)
    for x=1:size(od_image)
        if(img_vessel(y,x) == 1)
            od_image(y,x) = 0;
        end
    end
end

%Cluster the datapoints into regions using agglomerative clustering
disp('[CLUSTERING] Running the clustering algorithm');
[final_clusters, final_clusters_mask] = cluster_texture_regions(od_image);
figure(1), imagesc(final_clusters);

%Translate the cluster mask to the od_image
for y=1:size(final_clusters_mask,1)
    for x=1:size(final_clusters_mask,2)
        if (final_clusters_mask(y,x) > 0)
            od_image(y,x) = 1;
        else
            od_image(y,x) = 0;
        end
    end
end
% figure(2), imshow(img_vessel);
% figure(1), imshow(od_image);

%Remove the smaller disconnected regions as they are not likely to be an optic disc
% figure(2), imshowpair(od_image, img_vessel);

%Refine the possibilites of the optic disc using a vessel angle filter
pre_snaked_img = choose_od(od_image, img_vessel, img_angles);

%Use snaking algorithm to get smooth outline of the optic disc
disp('[SNAKES] Using Snaking algorithm to refine the edges of the optic disc');
Options=struct;
Options.Verbose=false;
Options.Iterations=200;
Options.Wedge=5;
Options.Wline = -0.04;
Points = get_box_coordinates(pre_snaked_img);
[~,snaked_optic_disc] = Snake2D(img, Points, Options); 

%Show the image result
% figure(3), imshowpair(snaked_optic_disc, img);

%Resize the image to its original size
snaked_optic_disc = imresize(snaked_optic_disc, [origy origx]);

%return the final image to the function caller
final_od_image = snaked_optic_disc;

%Report the time it took to classify to the user
e = cputime - t;
disp(['[TIME] Optic Disc Classification Time (min): ', num2str(e/60.0)]);

end
