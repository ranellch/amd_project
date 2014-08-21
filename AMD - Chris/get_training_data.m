function [ datafeatures, dataclass ] = get_training_data( I, Icolored, featuremask )
%REQUIRES: I is an AF image, Icolored is the 
%          same image as I with pixels in the class of interest colored red,
%          resize is bool for 768 by 768 scaling of Icolored
%          featuremask is a binary image that marks the location of vessels
%          and the optic disk
%EFFECTS: Returns datafeatures - array of feature vectors size numpixels x
%                   length of feature vectors
%                 dataclass - array of pixel classes -1 or 1 of size numpixels x 1

addpath(genpath('../ML Library'));

%assign pixels to their classes
classes = Icolored(:,:,3)>Icolored(:,:,2);
classes = double(classes);
classes(classes==0)=-1;

[h,w]=size(I);
numPixels = h*w;
dataclass = zeros(numPixels,1);

for i= 1:h
    for j= 1:w
        index= (i-1)*w+j;
        dataclass(index) = classes(i,j);
    end
end

%get feature vector array
datafeatures = get_feature_vectors(I, featuremask);

end

