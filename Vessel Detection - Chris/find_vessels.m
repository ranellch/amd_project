function [binary_img, mx_angs, corrected_img] = find_vessels(pid, eye, time, varargin)
%***ALL OUTPUT IMAGES 768 X 768
debug = -1;
imcomp = -1;
if length(varargin) == 1
    debug = varargin{1};
    valid_debug(debug);
elseif length(varargin) == 2
    imcomp = varargin{1};
    valid_imcomp(imcomp);
    
    debug = varargin{2};
    valid_debug(debug);
elseif isempty(varargin)
    debug = 1;
    imcomp = 0;
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
end
    
addpath('..');
addpath(genpath('../Test Set'));
addpath(genpath('../intensity normalization'))
addpath(genpath('../liblinear-1.94'))
addpath('../Chen-Vese ACWE')

%get image
path = get_pathv2(pid, eye, time, 'original');
img = imread(path);

%Pre-process
if (size(img, 3) > 1)
    img = rgb2gray(img(:,:,1:3));
end
img = crop_footer(img);

img = im2double(img);
if strcmp(imcomp, 'complement') == 1
    img = imcomplement(img);
end

origy = size(img,1);
origx = size(img,2);
img = imresize(img, [768 768]);
img = gaussian_filter(img);
[corrected_img, ~] = correct_illum(img,0.7);
img = imcomplement(corrected_img);
img = zero_m_unit_std(img);

%Load the classifier struct for this bad boy
model = load('vessel_combined_classifier.mat');
scaling_factors = model.scaling_factors;
classifier = model.vessel_combined_classifier;

%Build lineop features
%Time how long it takes 
t=cputime;
if(debug == 1 || debug == 2)
    disp('Running Line Operator!');
end

[lineop_image, mx_angs] = get_fv_lineop( img );

e = cputime - t;
if(debug == 1 || debug == 2)
    disp(['Time to build lineop features (min): ', num2str(e / 60.0)]);
end

%Time how long it takes to apply gabor 
t=cputime;
if(debug == 1 || debug == 2)
    disp('Building Gabor Features!');
end
%Run Gabor
gabor_image = get_fv_gabor(img);

%Disp some information to the user
e = cputime - t;
if(debug == 1 || debug == 2)
    disp(['Time to build gabor features (min): ', num2str(e / 60.0)]);
end



%Combine features
gabor_vectors = matstack2array(gabor_image);
lineop_vectors = matstack2array(lineop_image);
instance_matrix = [lineop_vectors, gabor_vectors];
clear gabor_vectors
clear lineop_vectors

% %Scale vectors
for i = 1:size(instance_matrix,2)
    fmin = scaling_factors(1,i);
    fmax = scaling_factors(2,i);
    instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
end

if(debug == 1 || debug == 2)
    disp('Running Pixelwise Classification ');
end
t=cputime;

%Do pixelwise classification
class_estimates = libpredict(zeros(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
    
%Output how long it took to do this
e = cputime-t;
if(debug == 1 || debug == 2)
    disp(['Classify (min): ', num2str(double(e) / 60.0)]);
end

% if(debug == 1 || debug == 2)
%     disp('Running Active Contour Without Edges');
% end
% t = cputime;

binary_img = zeros(size(img));
binary_img(:) = class_estimates;
binary_img = logical(binary_img);
% figure(2), imshow(display_mask(imcomplement(mat2gray(img)),binary_img,'red'))
% figure(1)
% subplot(1,2,1); imshow(binary_img); title('Before Level Set');

% c0 = 2;
% u = zeros(size(binary_img));
% u(binary_img) = c0;
% u(~binary_img) = -c0;
% 
% mu=1;
% lambda1=1; lambda2=1;
% timestep = .1; v= 0; epsilon=1;
% iterNum = 100;
% 
% weights = [sqrt(.33) sqrt(.33) sqrt(.33)]; %squared weights should sum to 1
% %normalize and weight
% for i = 1:size(lineop_image,3)
%     layer = lineop_image(:,:,i);
%     lineop_image(:,:,i) = (layer - min(layer(:)))/(max(layer(:))-min(layer(:)));
% %     lineop_image(:,:,i) = weights(i)*lineop_image(:,:,i);
% end     
% 
% %Run on sections of image at a time
% for i = 1:2
%     for j = 1:2
%         input = lineop_image((i-1)*384+1:i*384,(j-1)*384+1:j*384,1:3);
%         mask = binary_img((i-1)*384+1:i*384,(j-1)*384+1:j*384);
%         output = chenvese(input, mask, 400,0.02,'chan');
%         binary_img((i-1)*384+1:i*384,(j-1)*384+1:j*384)= imresize(output,[384, 384]);
%      end
%  end
% 
% 
% binary_img = u>0;
% figure(3), imshow(display_mask(imcomplement(mat2gray(img)),binary_img,'red'))
% 
% figure(1), subplot(1,2,2); imshow(binary_img); title('After Level Set');
% 
% e = cputime-t;
% if(debug == 1 || debug == 2)
%     disp(['ACWE (min): ', num2str(double(e) / 60.0)]);
% end

%Clean up image
CC = bwconncomp(binary_img);
stats = regionprops(CC,'Extent','Eccentricity');
for i = 1:length(stats)
    if stats(i).Extent > 0.15 && stats(i).Eccentricity < 0.95
        binary_img(CC.PixelIdxList{i}) = 0;
    end
end

%Resize the image to the original image size
% binary_img = imresize(binary_img, [origy origx]);


if debug == 2
     figure(1), imshow(binary_img);
end

end

function valid_debug(debug)
    try
        debug_isnum = num2str(debug);

        if(debug ~= 0 && debug ~= 1 && debug ~= 2)
            error('Varagin input from debug is not a valid number');
        end
    catch err
        error(err.message);
    end
end

function valid_imcomp(imcomp)
    gtg = 0;
    if(strcmp(imcomp, 'complement') == 1)
        gtg = 1;
    end
    if(strcmp(imcomp, 'none') == 1)
        gtg = 1;
    end

    if gtg == 0
        error('Varargin input for imcomp is incorrect');
    end
end
