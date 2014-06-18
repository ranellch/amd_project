function [ Iout, Ibin ] = classify_pixels(I, featuremask, model)
%REQUIRES: I is an AF image, model is a previously generated adaboost
%          classifier model
%EFFECTS: Returns Iout - colored image showing pixels in class of interest
%                       highlighted in red
%                 Ibin - binary image showing 1 for positive 0 for negative
addpath(genpath('../ML Library'));

%get features
datafeatures  = get_feature_vectors(I, featuremask);

%Classify the datafeatures with the trained model
  class_estimates=adaboost('apply',datafeatures,model);
 
%    class_estimates = Classify(Learners, Weights, datafeatures');
  %Put class back into image 

classes = zeros(size(I));
classes(~featuremask) = class_estimates;
    

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

