function [binary_img] = find_vessels(image, time, debug)
if(isnumeric(debug))
    %Add the path for the images
    addpath('..');
    addpath('../Test Set');
else
    error('debug parameters must b e anumber 0 or 1');
end

%Get the path name for the image and time
filename = get_path(image, time);
img = imread(filename);
if(size(img,3) ~= 1)
    img=rgb2gray(img);
end

%Resize the image for optimal vessel detection
orig_y = size(img, 1);
orig_x = size(img, 2);
img = match_sizing(img, 768, 768);

%Apply a gaussian filter to the image
img = gaussian_filter(img);

%Print to the console the output
disp(['ID: ', image, ' - Time: ', time, ' - Path: ', filename]);

%Load the classifier struct for this bad boy
load('gabor_vessel_classifier.mat', 'gabor_vessel_classifier');
load('lineop_vessel_classifier.mat', 'lineop_vessel_classifier');

%Time how long it takes to apply gabor and classify
t=cputime;

disp('Building Gabor Wavelets!');

%Apply the gabor function to the image
[gw_image] = apply_gabor_wavelet(img, 0);

binary_img_gabor = im2bw(img, 1.0);
for y=1:size(binary_img_gabor, 1)
    %Run the batched gabor wavelet classifier
    gabor_list = squeeze(gw_image(y,:,:));
    [~, out_gabor] = posterior(gabor_vessel_classifier, gabor_list);
    
    %Write to output image the vessel pixels
    for x=1:size(out_gabor, 1)
        binary_img_gabor(y,x) = out_gabor(x,1);
    end
end

if(debug == 1)
    figure(1), imshow(binary_img_gabor);
end

disp('Completed Classification with Gabor Wavelets!');


%Init the orthogonal line operator class
lineop_obj = line_operator(15, 8);
fv_image = zeros(size(img, 2), size(img, 1), 3);

disp('Running Line Operator!');

%Get the line operator feature vector for every pixel value
for y=1:size(fv_image, 1)
    for x=1:size(fv_image, 2)
        fv_image(y,x,:) = lineop_obj.get_fv(img, y, x);
    end
    
    if(debug == 1 && mod(y, 50) == 0)
        disp(['Rows: ', num2str(y), ' / ', num2str(size(binary_img_gabor, 1))]);
    end
end

%normalize the line operator feature vectors
fv_image = normalize_image_fv(fv_image);

binary_img_lineop = im2bw(img, 1.0);
for y=1:size(binary_img_lineop, 1)
    %Run the batched line operator classification
    fv_list = squeeze(fv_image(y,:,:));
    [~, out_lineop] = posterior(lineop_vessel_classifier, fv_list);

    %Write to output image the vessel pixels
    for x=1:size(out_lineop, 1)
        binary_img_lineop(y,x) = out_lineop(x,1);
    end
end

if(debug == 1)
    figure(2), imshow(binary_img_lineop);
end

disp('Completed Classification with Line Operator!');

%Do pixelwise classification
disp('Running Pixelwise Classification ');

binary_img = im2bw(img, 1.0);
for y=1:size(binary_img,1)
    for x=1:size(binary_img,2)
        if(binary_img_gabor(y,x) == 1 && binary_img_lineop(y,x) == 1)
            binary_img(y,x) = 1;
        else
            binary_img(y,x) = 0;
        end    
    end
end

%Output how long it took to do this
e = cputime-t;
disp(['Classify (min): ', num2str(double(e) / 60.0)]);

%Apply some morphological operations to clean up the small stuff
binary_img = bwmorph(binary_img, 'majority');
binary_img = bwareaopen(binary_img,25);

if(debug == 1)
    figure(3), imshow(binary_img);
end

%Resize the image back to original proportions
binary_img = match_sizing(binary_img, orig_x, orig_y);

end
