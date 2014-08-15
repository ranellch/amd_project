function [final_od_image, img_vessel, img_angles, probability, varargout] = find_od(pid, eye, time, varargin)
debug = -1;
resize = 'on';
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
elseif length(varargin) == 2
    debug = varargin{1};
    resize = varargin{2};
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
end

t = cputime;
std_imsize = 768;

%Add the path for the useful directories
addpath('..');
addpath(genpath('../Test Set'));
addpath('../intensity normalization');
addpath('../Chen-Vese ACWE');
addpath(genpath('../liblinear-1.94'))
addpath('../Skeleton');
addpath('../Vessel Detection - Chris');
        
%Load the prediction structs
model = load('od_classifiers.mat', 'scaling_factors','pixel_classifier');
scaling_factors = model.scaling_factors;
classifier = model.pixel_classifier;

%Print to the console the output
if(debug == 1 || debug == 0)
    disp(['[ID] ', pid, ' - Time: ', num2str(time)]);
end

%Get the vesselized image for now (need to change to find_vessels at some time)
if(debug == 1 || debug == 2)
    disp('[VESSELS] Run Vessel Detection Algorithm');
end
[img_vessel, img_angles, corrected_img] = find_vessels(pid,eye,time,debug);

%Get the dimensions of the original image
orig_img = imread(get_pathv2(pid,eye,time,'original'));
orig_img = crop_footer(orig_img);
origy = size(orig_img, 1);
origx = size(orig_img, 2);

%Initiate the results image
od_image = zeros(size(corrected_img, 1), size(corrected_img, 2));

%Get feature vectors for each pixel in image
if(debug == 1 || debug == 2)
    disp('[FV] Building the pixelwise feature vectors');
end
feature_image_g = get_fv_gabor_od(corrected_img);
feature_image_r = imfilter(corrected_img,ones(3)/9, 'symmetric');

%Build the finalized feature vector
feature_image = zeros(size(od_image,1), size(od_image,2), size(feature_image_g,3) + size(feature_image_r,3));

for y=1:size(feature_image, 1)
    for x=1:size(feature_image, 2)
        temp = 1;
        for z1=1:size(feature_image_g,3)
            feature_image(y,x,temp) = feature_image_g(y,x,z1);
            temp = temp + 1;
        end
        for z2=1:size(feature_image_r,3)
            feature_image(y,x,temp) = feature_image_r(y,x,z2);
            temp = temp + 1;
        end
    end
end

if nargout == 7
    varargout{1} = feature_image_g;
    varargout{2} = feature_image_r;
	varargout{3} = corrected_img; 
end

%convert this feature image into a flat array of feature vectors
instance_matrix = matstack2array(feature_image);

%Scale the vectors for input into the classifier
for i = 1:size(instance_matrix,2)
    fmin = scaling_factors(1,i);
    fmax = scaling_factors(2,i);
    instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
end

%Run the classification algorithm
if(debug == 1 || debug == 2)
    disp('[SVM] Running the classification algorithm');
end
% probs=zeros(size(od_image));
od_image(:) = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
% figure(10), imshow(mat2gray(probs))
clear instance_matrix

% if(debug == 2)
%     figure(1), imshow(od_image);
% end

%Remove all classified datapoints that were already classified as a vessel
positive_count = 0;
img_vessels_negatve = bwmorph(img_vessel, 'thicken', 5);
for y=1:size(od_image)
    for x=1:size(od_image)
        if(img_vessels_negatve(y,x) == 1)
            od_image(y,x) = 0;
        end
        if(od_image(y,x) == 1)
            positive_count = positive_count + 1;
        end
    end
end

%Cluster the datapoints into regions using agglomerative clustering
if(debug == 1 || debug == 2)
    disp(['[CLUSTERING] Running the clustering algorithm (', num2str(positive_count), ')']);
end

%Run the clustering algorithm if there are regions to cluster
if(positive_count > 10)
    final_clusters = cluster_texture_regions(od_image, debug);
else
    final_od_image = od_image;
    return;
end

if(debug == 2)
    figure(2), imagesc(final_clusters);
    colormap(jet)
end

% %Translate the cluster mask to the od_image
% for y=1:size(final_clusters_mask,1)
%     for x=1:size(final_clusters_mask,2)
%         if (final_clusters_mask(y,x) > 0)
%             od_image(y,x) = 1;
%         else
%             od_image(y,x) = 0;
%         end
%     end
% end
% 
% if(debug == 2)
%     figure(4), imshowpair(od_image, img_vessel);
% end

%Find optic disk region using another classifier]
if(debug == 1 || debug == 2)
    disp('[REGIONS] Running region classification');
end
[od_img, probability] = choose_od(final_clusters, img_vessel, img_angles, debug);
if ~any(od_img(:))
    if strcmp(resize,'on')
        final_od_image = imresize(od_img,[origy,origx]);
    else 
        final_od_image = od_img;
    end
    disp('Optic Disk Not Found!')
    return
end
if (debug == 2)
    figure(4), imshowpair(od_img,img_vessel)
end
if(debug == 1 || debug == 2)
    disp('[ACWE] Running final segmentation');
end
Points = get_box_coordinates(od_img);
%setting the initial level set function 'u':
% c0=2;
% u = ones(size(od_img))*-c0;
% u(od_img==1)=c0;
bb_t = max([1,min(Points(:,1))-100]);
bb_b = min([std_imsize,max(Points(:,1))+100]);
bb_l = max([1,min(Points(:,2))-100]);
bb_r = min([std_imsize,max(Points(:,2))+100]);
textures = feature_image_g;
% for i = 1:size(feature_image_g,3)
%     textures(:,:,i) = feature_image_g(:,:,i);
% end
feature_window = cat(3,corrected_img(bb_t:bb_b,bb_l:bb_r),textures(bb_t:bb_b,bb_l:bb_r,:));
% weights = [sqrt(.5) sqrt(.1) sqrt(.1) sqrt(.1) sqrt(.1) sqrt(.1)]; %squared weights should sum to 1
%normalize and weight
for i = 1:size(feature_window,3)
    layer = feature_window(:,:,i);
    feature_window(:,:,i) = (layer - min(layer(:)))/(max(layer(:))-min(layer(:)));
%     feature_window(:,:,i) = weights(i)*feature_window(:,:,i);
end
mask = od_img(bb_t:bb_b,bb_l:bb_r);
output = chenvese(feature_window,mask,200,0.02,'vector'); 
%setting the parameters in ACWE algorithm:
% mu=1;
% lambda1=1; lambda2=1;
% timestep = .1; v=0; epsilon=1;
% iterNum = 400;
%show the initial 0-level-set contour:
% figure;imshow(window, []);hold on;axis off,axis equal
% title('Initial contour');
% [c,h] = contour(u,[0 0],'r');
% pause(0.1);
% start level set evolution
% % for n = i:iterNum
%     u=acwe(u, feature_window, vessels, timestep,...
%              mu, v, lambda1, lambda2, 1, epsilon, iterNum);
%     if mod(n,10)==0
%         pause(0.1);
%         imshow(window, []);hold on;axis off,axis equal
%         [c,h] = contour(u,[0 0],'r');
%         iterNum=[num2str(n), ' iterations'];
%         title(iterNum);
%         hold off;
%     end
% end
% imshow(window, []);hold on;axis off,axis equal
% [c,h] = contour(u,[0 0],'r');
% totalIterNum=[num2str(n), ' iterations'];
% title(['Final contour, ', totalIterNum]);

% if debug == 2
%     figure(5);
%     imagesc(u);axis off,axis equal;
%     title('Final level set function');
% end
% 
% binary_img = u>0;


binary_img = zeros(size(od_img));
binary_img(bb_t:bb_b,bb_l:bb_r) = imresize(output,[bb_b-bb_t+1, bb_r-bb_l+1]);
binary_img(img_vessel==1) = 0;

% Clean up image, only keep biggest blob
final_od_image = zeros(size(od_image));
CC = bwconncomp(binary_img);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
final_od_image(CC.PixelIdxList{idx}) = 1;
final_od_image = imfill(final_od_image,'holes');

final_od_image = im2bw(final_od_image);

% %Use snaking algorithm to get smooth outline of the optic disc
% if(debug == 1 || debug == 2)
%     disp('[SNAKES] Using Snaking algorithm to refine the edges of the optic disc');
% end

% Options=struct;
% % if debug == 2
%      Options.Verbose=true;
% % else 
%    % Options.Verbose=false;
% % end
% Options.Iterations=200;
% Options.Wedge=10;
% Options.Wline = .5;
% Options.Wterm = 10;
% Options.Delta = .2;

% pre_snaked_img = mat2gray(feature_image_g(:,:,1)); 
% figure, imshow(pre_snaked_img)
% [~,snaked_optic_disc] = Snake2D(pre_snaked_img, Points, Options); 

if(debug == 2)
    %Show the image result
    figure(6), imshowpair(final_od_image, corrected_img);
end

%Resize the image to its original size
if strcmp(resize,'on')
    final_od_image = imresize(final_od_image, [origy origx]);
end
    

%Report the time it took to classify to the user
e = cputime - t;
if(debug == 1 || debug ==2)
    disp(['[TIME] Optic Disc Classification Time (min): ', num2str(e/60.0)]);
end

end
