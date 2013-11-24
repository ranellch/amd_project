function [x,y] = find_od(image, time)
%Standardize variables
std_img_size = 768;
num_of_pixels = 16;

%Add the path for the images
addpath('..');
addpath('../Test Set');
addpath('../intensity normalization');
addpath('sfta');

%Get the path name for the image and time
filename = get_path(image, time);
img = imread(filename);
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

img = match_sizing(img, std_img_size, std_img_size);

%Print to the console the output
disp(['ID: ', image, ' - Time: ', time]);

%Load the prediction structs
load('int_od_bayesstruct.mat', 'int_prediction_bayesstruct');
load('text_od_bayesstruct.mat', 'text_prediction_bayesstruct');
load('combined_od_bayesstruct.mat', 'combined_od_bayesstruct');

x=-1;
y=-1;

%iterate over each segement
t=cputime;
[classed_img, ~] = apply_segment_classify(img, num_of_pixels, text_od_bayesstruct, int_od_bayesstruct, combined_od_bayesstruct);
imshowpair(classed_img, img);
e = cputime-t;
disp(['Classify (sec): ', num2str(e)]);

end