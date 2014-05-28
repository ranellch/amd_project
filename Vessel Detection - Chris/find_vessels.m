function [binary_img] = find_vessels(img)
addpath('..');
addpath(genpath('../Test Set'));
addpath(genpath('../intensity normalization'))

%Pre-process
if (size(img, 3) > 1)
    img = rgb2gray(img);
end
img = crop_footer(img);
img = imresize(img, [768 768]);
img = gaussian_filter(img);
[img, ~] = smooth_illum3(img,0.7);
img = imcomplement(img);

% %Print to the console the output
% disp(['ID: ', image, ' ', eye,' - Time: ', time, ' - Path: ', filename]);

%Load the classifier struct for this bad boy
% load('vessel_gabor_classifier.mat', 'vessel_gabor_classifier');
% load('vessel_lineop_classifier.mat', 'vessel_lineop_classifier');
classifier = load('vessel_combined_classifier.mat');
classifier = classifier.vessel_combined_classifier;

%Time how long it takes to apply gabor 
t=cputime;
disp('Building Gabor Features!');

%Run Gabor, save max at each scale, normalize via zero_m_unit_std 
    [sizey, sizex] = size(img);
    bigimg = padarray(img, [50 50], 'symmetric');
    fimg = fft2(bigimg);
    k0x = 0;
    k0y = 3;
    epsilon = 4;
    step = 10;
    gabor_image = [];
    for a = [1 2 3 4 5]
        trans = maxmorlet(fimg, a, epsilon, [k0x k0y], step);
        trans = trans(51:(50+sizey), (51:50+sizex));
        gabor_image = cat(3, gabor_image, zero_m_unit_std(trans));
    end


%Disp some information to the user
e = cputime - t;
disp(['Time to build gabor features (min): ', num2str(e / 60.0)]);


%Build lineop features
%Time how long it takes 
t=cputime;
disp('Running Line Operator!');
lineop_image = get_fv_lineop( img );
e = cputime - t;
disp(['Time to build lineop features (min): ', num2str(e / 60.0)]);

%Combine features
gabor_vectors = matstack2array(gabor_image);
lineop_vectors = matstack2array(lineop_image);
combined_vectors = [gabor_vectors, lineop_vectors];

%Do pixelwise classification
disp('Running Pixelwise Classification ');
t=cputime;

% class_estimates=adaboost('apply',combined_vectors,classifier);
class_estimates = [];
increment = length(combined_vectors)/512;
for start = 1:increment:length(combined_vectors)
    class_estimates = [class_estimates; svmclassify(classifier, combined_vectors(start:start+increment-1,:))];
end

%Output how long it took to do this
e = cputime-t;
disp(['Classify (min): ', num2str(double(e) / 60.0)]);

binary_img = zeros(size(img));
binary_img(:) = class_estimates;
binary_img(binary_img==-1) = 0;

% %Remove the border because it tends to not be that clean
% border_remove = 10;
% for y=1:size(binary_img,1)
%     for x=1:size(binary_img, 2)
%         if(y < border_remove || x < border_remove || ...
%            y > (size(binary_img, 1) - border_remove) || ...
%            x > (size(binary_img, 2) - border_remove))
%             binary_img(y,x) = 0;
%         end
%     end
% end
% 
% %Apply morolgical operation to smooth out the edges
% binary_img = bwmorph(binary_img, 'majority');
% 
% %Apply morphological operations to clean up the small stuff
% binary_img = bwareaopen(binary_img,60);
% 
% if(debug == 1)
%     figure(3), imshow(binary_img);
% end

%Resize the image back to original proportions
% binary_img = match_sizing(binary_img, orig_x, orig_y);

end
