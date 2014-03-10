function [ Iout, class_estimates ] = classify_pixels( I, model, resize)
%REQUIRES: I is an image matrix, model is a previously generated adaboost
%          classifier model
%EFFECTS: Returns Iout - colored image showing pixels in class of interest
%                       highlighted in red
%                 class_estimates - array of pixel classes -1 or 1 of size numpixels x 1


if length(size(I))==3
       I=rgb2gray(I);
end
I=im2double(I);
I = crop_footer(I);
if resize
     I=imresize(I, [768 768]);
end

H=fspecial('Gaussian',[5 5], 1);
Iblurred=imfilter(I,H);

%Run Gabor Filtering
gabors = apply_gabor_wavelet(Iblurred,0);

stdI=std(I(:));
meanI=mean2(I);
[h,w]=size(I);
numPixels = h*w;
datafeatures = zeros(numPixels,size(gabors,3)+1);
for i= 1:h
    for j= 1:w
        index= (i-1)*w+j;
        datafeatures(index,1:size(gabors,3)) = gabors(i,j,:);
        datafeatures(index,size(gabors,3)+1) = (I(i,j)-meanI)./stdI;
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

clear gabors

end

