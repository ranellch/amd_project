function [binary_img] = find_vessels(image, time)
%Add the path for the images
addpath('..');
addpath('../Test Set');

%Get the path name for the image and time
filename = get_path(image, time);
img = imread(filename);
if(size(img,3) ~= 1)
    img=rgb2gray(img);
end

%Print to the console the output
disp(['ID: ', image, ' - Time: ', time, ' - Path: ', filename]);

%Load the classifier struct for this bad boy
load('vessel_classifier.mat', 'vessel_classifier');

%Time how long it takes to apply gabor and classify
t=cputime;

%Apply the gabor function to the image
[gw_image] = apply_gabor_wavelet(img, 0);
disp('Done Running Gabor Wavelets!');

%Create variables for classification
binary_img = im2bw(img, 1.0);
vector_test = zeros(1, size(gw_image, 3));

%Do pixelwise classification
disp('Running Pixelwise Classification ');
for y=1:size(binary_img, 1)
    temp_vec = squeeze(gw_image(y,:,:));
    [~, out] = posterior(vessel_classifier, temp_vec);

    for x=1:size(out, 1)
        %Apply the classification to the binary image
        binary_img(y,x) = out(x,1);
    end
end

%Output how long it took to do this
e = cputime-t;
disp(['Classify (min): ', num2str(double(e) / 60.0)]);

end
