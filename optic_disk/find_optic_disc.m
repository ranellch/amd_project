function [x,y,shift] = find_optic_disc(image, time, num_of_pixels)
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

%Calculate the mean shift
t=cputime;
shift=mean_shift_segment(img);
e = cputime-t;
disp(['Mean Shift (sec): ', num2str(e)]);


%Load the prediction structs
load('int_prediction_struct.mat', 'int_prediction_struct');
load('text_prediction_struct.mat', 'text_prediction_struct');

x=-1;
y=-1;

%iterate over each segement
iterate_segments(filename, img, shift, num_of_pixels, 0.99, text_prediction_struct, int_prediction_struct);

end