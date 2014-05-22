function [od_image] = find_od(image, time, debug)
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
img = im2double(img);

%Convert the image to gray scale if not already
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

%Apply a gaussian filter to the image
img = gaussian_filter(img);

%Resize the image to a standard size
origy = size(img, 1);
origx = size(img, 2);
img = match_sizing(img, std_img_size, std_img_size);

%Print to the console the output
disp(['ID: ', image, ' - Time: ', time]);

%Load the prediction structs
load('od_text_bayesstruct.mat', 'od_text_bayesstruct');

x=-1;
y=-1;

%iterate over each segement
t=cputime;

od_image = zeros(size(img, 1), size(img, 2));

%Get the gabor wavelet for this image
orig_wavelets = apply_gabor_wavelet(img, debug);

%Create the img pixel feature vector
img_fv = zeros(size(orig_wavelets, 1), size(orig_wavelets, 2), size(orig_wavelets, 3) + 1);

for y=1:size(orig_wavelets, 1)
    for x=1:size(orig_wavelets, 2)
        for wv=1:size(orig_wavelets, 3)
            img_fv(y,x,wv) = orig_wavelets(y,x,wv);
        end
        size(size(orig_wavelets, 3));
        disp(wv);
        img_fv(y,x,wv) = img(y,x);
    end
end

for y=1:size(orig_wavelets, 1)
    row_fv = squeeze(img_fv(y,:,:));
    grouping = predict(od_text_bayesstruct, row_fv);
    for x=1:size(orig_wavelets, 2)
        od_image(y,x) = grouping(x,1);
    end
end

figure(1), imshowpair(od_image, img);

%Resize the image to its original size
od_image = match_sizing(od_image, origx, origy);

e = cputime-t;
disp(['Classify (min): ', num2str(e / 60.0)]);

end