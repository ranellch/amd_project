function [x,y] = find_od(image, time, debug)
%Standardize variables
std_img_size = 768;
num_of_pixels = 8;

%Add the path for the images
addpath('..');
addpath('../Test Set');
addpath('../intensity normalization');
addpath('sfta');

%Get the path name from the image and time and then read in the image.
filename = get_path(image, time);
img = imread(filename);

%Convert the image to gray scale if not already
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

%Apply a gaussian filter to the image
img = gaussian_filter(img);

%Resize the image to a standard size
img = match_sizing(img, std_img_size, std_img_size);

%Print to the console the output
disp(['ID: ', image, ' - Time: ', time]);

%Load the prediction structs
load('int_od_bayesstruct.mat', 'int_od_bayesstruct');
load('text_od_bayesstruct.mat', 'text_od_bayesstruct');
load('combined_od_bayesstruct.mat', 'combined_od_bayesstruct');

x=-1;
y=-1;

%iterate over each segement
t=cputime;

[classed_img] = apply_segment_classify(img, num_of_pixels, text_od_bayesstruct, int_od_bayesstruct, combined_od_bayesstruct, debug);
figure(1), imshowpair(classed_img, img);

e = cputime-t;
disp(['Classify (min): ', num2str(e / 60.0)]);

end