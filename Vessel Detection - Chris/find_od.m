function [final_od_image] = find_od(pid, eye, time)
%Standardize variables
std_img_size = 768;
 t = cputime;

%Add the path for the useful directories
addpath('..');
addpath(genpath('../Test Set'));
addpath('../intensity normalization');
addpath(genpath('../sfta'));
addpath('../snake');
run('../vlfeat/toolbox/vl_setup');
addpath(genpath('../liblinear-1.94'))
        
%Get the path name from the image and time and then read in the image.
filename = get_pathv2((pid), (eye), num2str(time), 'original');
img = imread(filename);
img = im2double(img);

%Get the vesselized image for now (need to change to find_vessels at some time)
filename_vessel = get_pathv2(pid, eye, num2str(time), 'vessels');
img_vessel = im2double(imread(filename_vessel));

%Convert the image to gray scale if not already
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

%Apply a gaussian filter to the image
img = gaussian_filter(img);
[img, ~] = smooth_illum3(img, 0.7);

%Resize the image to a standard size
origy = size(img, 1);
origx = size(img, 2);
img = match_sizing(img, std_img_size, std_img_size);

%Print to the console the output
disp(['ID: ', pid, ' - Time: ', num2str(time)]);

%Load the prediction structs
model = load('od_classify_svmstruct.mat');
scaling_factors = model.scaling_factors;
classifier = model.od_classify_svmstruct;

x=-1;
y=-1;

od_image = zeros(size(img, 1), size(img, 2));

%Get feature vectors for each pixel in image
feature_image_g = get_fv_gabor(img);
feature_image_r = rangefilt(img);

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

%convert this feature image into a flat array of feature vectos
instance_matrix = matstack2array(feature_image);

%Scale vectors
for i = 1:size(instance_matrix,2)
    fmin = scaling_factors(1,i);
    fmax = scaling_factors(2,i);
    instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
end

%Run the classification algorithm
class_estimates = libpredict(zeros(length(instance_matrix),1), sparse(instance_matrix), classifier);

%Classify the feature vectors for each pixel
%for y=1:size(feature_image, 1)
%    temp_rearrange = squeeze(feature_image(y,:,:));
%    class_estimates = svmclassify(od_classify_svmstruct, temp_rearrange);
%    for x=1:size(feature_image, 2)
%        od_image(y,x) = class_estimates(x);
%    end
%end

od_image(:) = class_estimates;

%Close the image so that all the little pices close together become connected
od_image = imclose(od_image, strel('disk',5));
od_image = imfill(od_image,'holes');

%Remove the smaller disconnected regions as they are not likely to be an optic disc
od_image = imopen(od_image, strel('disk', 5));
    
%Refine the possibilites of the optic disc
pre_snaked_img = refine_od(od_image, img_vessel);

%Use snaking algorithm to get smooth outline of the optic disc
Options=struct;
Options.Verbose=false;
Options.Iterations=200;
Options.Wedge=3;
Points = get_box_coordinates(pre_snaked_img);
[~,snaked_optic_disc] = Snake2D(img, Points, Options); 

%Resize the image to its original size
snaked_optic_disc = match_sizing(snaked_optic_disc, origx, origy);

imshowpair(snaked_optic_disc, img);

%return the final image to the function caller
final_od_image = snaked_optic_disc;

e = cputime - t;
disp(['Optic Disc Classification Time (sec): ', num2str(e)]);
    
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