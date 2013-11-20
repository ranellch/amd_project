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
load('gabor_vessel_classifier.mat', 'gabor_vessel_classifier');
load('lineop_vessel_classifier.mat', 'lineop_vessel_classifier');

%Time how long it takes to apply gabor and classify
t=cputime;

%Apply the gabor function to the image
[gw_image] = apply_gabor_wavelet(img, 0);
disp('Done Running Gabor Wavelets!');

%Init the orthogonal line operator class
lineop_obj = line_operator(15, 8);
fv_list = zeros(size(img, 2), 3);

%Create variables for results from classification
binary_img = im2bw(img, 1.0);
binary_img_gabor = im2bw(img, 1.0);
binary_img_lineop = im2bw(img, 1.0);

%Do pixelwise classification
disp('Running Pixelwise Classification ');
for y=1:size(binary_img, 1)
    %For the current row classify each pixel using gabor wavelets
    temp_vec = squeeze(gw_image(y,:,:));
    [~, out_gabor] = posterior(gabor_vessel_classifier, temp_vec);

    %For each pixel that is classified as vessel mark it for line operator classification
    %x_indicies = zeros(size(out_gabor, 1), 1);
    %fv_list = zeros(size(out_gabor, 1), 3);
    %current_index = 0;
    %for x=1:size(out_gabor, 1)
    %    if(out_gabor(x, 1) == 1)
    %        current_index = current_index + 1;
    %        fv_list(current_index, :) = lineop_obj.get_fv(img, y, x);
    %    end
    %    x_indicies(x, 1) = current_index;
    %end

    %Get the line operator for each pixel in this bad boy
    for x=1:size(out_gabor, 1)
        fv_list(x, :) = lineop_obj.get_fv(img, y, x);
    end

    %Run the batched line operator classification
    [~, out_lineop] = posterior(lineop_vessel_classifier, fv_list);

    %Write to output image the vessel pixels
    for x=1:size(out_gabor, 1)
        binary_img_gabor(y,x) = out_gabor(x,1);
        binary_img_lineop(y,x) = out_lineop(x,1);

        if(out_gabor(x, 1) == 1 && out_lineop(x, 1) == 1)
            binary_img(y,x) = 1;
        else
            binary_img(y,x) = 0;
        end
    end

    if(mod(y, 50) == 0)
        disp(['Rows: ', num2str(y), ' \ ', num2str(size(binary_img, 1))]);
    end
end

%Output how long it took to do this
e = cputime-t;
disp(['Classify: ', num2str(double(e) / 60.0), ' minutes']);

figure(1), imshow(binary_img_gabor);
figure(2), imshow(binary_img_lineop);

%Apply some morphological operations to clean up the small stuff
binary_img = bwmorph(binary_img, 'majority');
binary_img = bwareaopen(binary_img,25);

figure(3), imshow(binary_img);
end
