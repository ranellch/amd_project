function [x,y] = find_vessels(image, time)
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

load('vessel_classifier.mat', 'vessel_classifier');

%iterate over each segement
t=cputime;



e = cputime-t;
disp(['Classify (sec): ', num2str(e)]);

end