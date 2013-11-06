function [gw_image, comb] = find_vessels(image, time)
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
disp(['ID: ', image, ' - Time: ', time]);

%Load the classifier struct for this bad boy
load('vessel_classifier.mat', 'vessel_classifier');

%Time how long it takes to apply gabor and classify
t=cputime;

%Apply the gabor function to the image
[gw_image] = apply_gabor_wavelet(img);
%figure(1), imshow(comb);

%Create variables for classification
binary_img = im2bw(img, 1.0);
vector_test = zeros(1, size(gw_image, 3));

%Do pixelwise classification
for y=1:size(binary_img, 1)
    for x=1:size(binary_img, 2)
        %Get the vector from the gabor wavelets
        for wave=1:size(gw_image, 3)
            vector_test(1,wave) = gw_image(y,x,wave);
        end

        %Get the classification
        [~, out] = posterior(vessel_classifier, vector_test);
        
        %Apply the classification to the binary image
        binary_img(y,x) = out;
    end
end

%Output how long it took to do this
e = cputime-t;
disp(['Classify (sec): ', num2str(e)]);

%Show the binary map
figure(2), imshow(binary_img);

end
