function [ Iout, Ibin ] = classify_pixels( I, Iearly, model)
%REQUIRES: I and Iearly are registered late and early stage FAs, respectively, model is a previously generated adaboost
%          classifier model
%EFFECTS: Returns Iout - colored image showing pixels in class of interest
%                       highlighted in red
%                 Ibin - binary image showing 1 for positive 0 for negative
addpath(genpath('../ML Library'));

I=im2double(I);
Iearly=im2double(Iearly);


%Gaussian filter early and late images
H=fspecial('Gaussian',[3 3], 1);
I=imfilter(I,H);
Iearly=imfilter(Iearly,H);

%Run Gabor Filtering on late image
gabors = apply_gabor_wavelet(I,0);

%Get difference image
%normalize intensities
Inorm = (I-mean2(I))./std(I(:));
Iearly(Iearly~=0) = (Iearly(Iearly~=0)-mean(Iearly(Iearly~=0)))./std(Iearly(Iearly~=0));
Idiff = Inorm-Iearly;
%flag pixels for which no early stage exists
Idiff(Iearly==0) = -1000;

[h,w]=size(I);
numPixels = h*w;
datafeatures = zeros(numPixels,size(gabors,3)+1);
for i= 1:h
    for j= 1:w
        index= (i-1)*w+j;
        datafeatures(index,1:size(gabors,3)) = gabors(i,j,:);
        datafeatures(index,size(gabors,3)+1) = Idiff(i,j);
    end
end

% Classify the datafeatures with the trained model
  class_estimates=adaboost('apply',datafeatures,model);
 
%    class_estimates = Classify(Learners, Weights, datafeatures');
  %Put class back into image 

classes = zeros(size(I));
for i = 1:h
    for j = 1:w
        index = (i-1)*w+j;
        classes(i,j)= class_estimates(index);
    end
end
    

 % Show result
[Iind,map] = gray2ind(I,256);
Irgb=ind2rgb(Iind,map);
Ihsv = rgb2hsv(Irgb);
hueImage = Ihsv(:,:,1);
hueImage(classes==1) = 0.011; %red
Ihsv(:,:,1) = hueImage;
satImage = Ihsv(:,:,2);
satImage(classes==1) = .8; %semi transparent
Ihsv(:,:,2) = satImage;
Iout = hsv2rgb(Ihsv);

% figure, imshow(Iout)
Ibin = classes;
clear gabors

end

