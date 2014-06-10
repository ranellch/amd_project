function [final_od_image] = find_od(pid, eye, time)
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
img = im2double(img);

%Get the vesselized image for now (need to change to find_vessels at some time)
disp('[VESSELS] Run Vessel Detection Algorithm');
[img_vessel, img_angles] = find_vessels(pid,eye,time);
CC = bwconncomp(img_vessel);
stats = regionprops(CC,'Eccentricity','Area');
idx = find([stats.Area] > 50 & [stats.Eccentricity] > 0.9);
img_vessel = ismember(labelmatrix(CC), idx);

%Convert the image to gray scale if not already
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

%Get the longest dimension of the original image
origaxis = 0;
origy = size(img, 1);
origx = size(img, 2);
if origy >= origx
    origaxis = origy;
else
    origaxis = origx;
end

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
class_estimates = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier);
clear instance_matrix
od_image(:) = class_estimates;

%User morphological cleaning to get wholly connected regions
od_image = bwareaopen(od_image, 200);
od_image = imfill(od_image,'holes');
od_image = imclose(od_image, strel('disk',5));

2figure(1), imshow(od_image);
return;

%Use canny edge detector to smooth out the edges of the possible optic discs
od_image = edge(od_image, 'canny', [], sqrt(100));
od_image = imdilate(od_image, strel('disk',5));

%Fill in all the holes by adding a border and then removing it
od_image(1:size(od_image,1), 1) = 1;
od_image = imfill(od_image, 'holes');
od_image(1:size(od_image,1), 1) = 0;

od_image(1:size(od_image,1), size(od_image,2)) = 1;
od_image = imfill(od_image, 'holes');
od_image(1:size(od_image,1), size(od_image,2)) = 0;

od_image(1, 1:size(od_image,2)) = 1;
od_image = imfill(od_image, 'holes');
od_image(1, 1:size(od_image,2)) = 0;

od_image(size(od_image,1), 1:size(od_image,2)) = 1;
od_image = imfill(od_image, 'holes');
od_image(size(od_image,1), 1:size(od_image,2)) = 0;

%Remove the smaller disconnected regions as they are not likely to be an optic disc
figure(1), imshowpair(od_image, img_vessel);

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
figure(3), imshowpair(snaked_optic_disc, img);

%Resize the image to its original size
snaked_optic_disc = imresize(snaked_optic_disc, [origy origx]);

%return the final image to the function caller
final_od_image = snaked_optic_disc;

%Report the time it took to classify to the user
e = cputime - t;
disp(['[TIME] Optic Disc Classification Time (min): ', num2str(e/60.0)]);

end

function other()
number_of_pixels_per_box = 8;
%Divide the image up into equal sized boxes
subimage_size = floor(std_img_size / number_of_pixels_per_box);

if 0
    %This is a window based feature descriptor
    for x=1:subimage_size
        for y=1:subimage_size
            xs = ((x - 1) * number_of_pixels_per_box) + 1;
            xe = xs + number_of_pixels_per_box - 1;

            ys = ((y - 1) * number_of_pixels_per_box) + 1;
            ye = ys + number_of_pixels_per_box - 1;

            if(ye > size(img, 1))
                ye = size(img, 1);
                ys = ye - number_of_pixels_per_box;
            end
            if(xe > size(img, 2))
                xe = size(img, 2);
                xs = xe - number_of_pixels_per_box;
            end

            %Get the original image window
            subimage = img(ys:ye, xs:xe);

            feature_vectors = text_algorithm(subimage);
            grouping = svmclassify(od_classify_svmstruct, feature_vectors);

            for xt=xs:xe
                for yt=ys:ye
                    od_image(yt,xt) = grouping;
                end
            end
        end
    end        
elseif 0
    texture_results = vl_hog(single(img), number_of_pixels_per_box, 'verbose') ;

    for y=1:size(texture_results,1)
        for x=1:size(texture_results,2)
            class_estimates = svmclassify(od_classify_svmstruct, squeeze(texture_results(y,x,:)).');

            od_image(((y-1)*number_of_pixels_per_box)+1:y*number_of_pixels_per_box, ((x-1)*number_of_pixels_per_box)+1:x*number_of_pixels_per_box) = class_estimates;
        end
    end
end
end