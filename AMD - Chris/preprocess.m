function [ I, Ilabeled, featuremask] = preprocess( I, Ilabeled, resize )
%Returns illumination corrected I of the right size, type, and cropping for
%later feature vector extraction
%Note that Ilabeled can be replaced with [] if not relevent

addpath(genpath('../intensity normalization'))

I=im2double(I);
if size(I,3) > 1
    I = rgb2gray(I);
end
I = crop_footer(I);
if resize
    I = imresize(I, [768 768]);
end

%Gaussian filter 
H=fspecial('Gaussian',[3 3], 1);
I=imfilter(I,H);

%Run initial illumination correction
[I, ~]=smooth_illum3(I, 0.7);

%Detect vessels

if ~isempty(Ilabeled)
    if size(Ilabeled,3)>3
        Ilabeled=Ilabeled(:,:,1:3);
    end
    Ilabeled = crop_footer(Ilabeled);
    if resize
        Ilabeled=imresize(Ilabeled, [768 768]);
    end
end

end

