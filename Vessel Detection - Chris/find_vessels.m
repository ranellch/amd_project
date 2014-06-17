function [binary_img, mx_angs] = find_vessels(pid, eye, time, varargin)
debug = -1;
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
end
    
addpath('..');
addpath(genpath('../Test Set'));
addpath(genpath('../intensity normalization'))
addpath(genpath('../libsvm-3.18'))
addpath(genpath('../liblinear-1.94'))

%get image
path = get_pathv2(pid, eye, time, 'original');
img = imread(path);

%Pre-process
if (size(img, 3) > 1)
    img = rgb2gray(img);
end
img = crop_footer(img);
img = imresize(img, [768 768]);
img = gaussian_filter(img);
[img, ~] = correct_illum(img,0.7);
img = imcomplement(img);
img = zero_m_unit_std(img);

% %Print to the console the output
% disp(['ID: ', image, ' ', eye,' - Time: ', time, ' - Path: ', filename]);

%Load the classifier struct for this bad boy
% load('vessel_gabor_classifier.mat', 'vessel_gabor_classifier');
% load('vessel_lineop_classifier.mat', 'vessel_lineop_classifier');
model = load('vessel_combined_classifier.mat');
scaling_factors = model.scaling_factors;
classifier = model.vessel_combined_classifier;

%Time how long it takes to apply gabor 
t=cputime;
if(debug == 1 || 2)
    disp('Building Gabor Features!');
end

%Run Gabor, save max at each scale, take absolute maximums
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
    gabor_image = cat(3, gabor_image, trans);
end

%Disp some information to the user
e = cputime - t;
if(debug == 1 || 2)
    disp(['Time to build gabor features (min): ', num2str(e / 60.0)]);
end


%Build lineop features
%Time how long it takes 
t=cputime;
if(debug == 1 || 2)
    disp('Running Line Operator!');
end
[lineop_image, mx_angs] = get_fv_lineop( img );
e = cputime - t;
if(debug == 1 || 2)
    disp(['Time to build lineop features (min): ', num2str(e / 60.0)]);
end

%Combine features
gabor_vectors = matstack2array(gabor_image);
lineop_vectors = matstack2array(lineop_image);
instance_matrix = [gabor_vectors, lineop_vectors];
clear gabor_vectors
clear lineop_vectors
%  libsvmwrite('vessel_test.dataset',zeros(length(combined_vectors),1),sparse(combined_vectors));
% 
% %Scale vectors
for i = 1:size(instance_matrix,2)
    fmin = scaling_factors(1,i);
    fmax = scaling_factors(2,i);
    instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
end
%   system('..\libsvm-3.18\windows\svm-scale -r vessel_training.subset.range vessel_test.dataset > vessel_test.dataset.scale');
%   [~, scaled_vectors] = libsvmread('vessel_test.dataset.scale');

%Do pixelwise classification
if(debug == 1 || 2)
    disp('Running Pixelwise Classification ');
end
t=cputime;

class_estimates = libpredict(zeros(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
% chunk_size = 512;
% class_estimates = [];
% for i = 1:chunk_size:length(combined_vectors)
%     class_estimates = [class_estimates; svmclassify(classifier, combined_vectors(i:i+chunk_size-1, :))]; 
% end
    
%Output how long it took to do this
e = cputime-t;
if(debug == 1 || 2)
    disp(['Classify (min): ', num2str(double(e) / 60.0)]);
end

binary_img = zeros(size(img));
binary_img(:) = class_estimates;
binary_img(binary_img==-1) = 0;
binary_img = logical(binary_img);

%Clean up image
CC = bwconncomp(binary_img);
stats = regionprops(CC,'Extent','Eccentricity');
for i = 1:length(stats)
    if stats(i).Extent > 0.15 && stats(i).Eccentricity < 0.95
        binary_img(CC.PixelIdxList{i}) = 0;
    end
end

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
