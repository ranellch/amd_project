function [x,y] = find_od(image, time, num_of_pixels)
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

%Print to the console the output
disp(['ID: ', image, ' - Time: ', time]);

%Load the prediction structs
load('int_prediction_bayesstruct.mat', 'int_prediction_bayesstruct');
load('text_prediction_bayesstruct.mat', 'text_prediction_bayesstruct');

x=-1;
y=-1;

%iterate over each segement
t=cputime;
[classed_img, ~] = apply_segment_classify(img, num_of_pixels, text_prediction_bayesstruct, int_prediction_bayesstruct);
imshowpair(classed_img, img);
e = cputime-t;
disp(['Classify (sec): ', num2str(e)]);

end