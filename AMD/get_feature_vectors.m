function [ datafeatures ] = get_feature_vectors( I, featuremask )
%Returns array of feature vectors given for every pixel in pre-processed
%image I, while discarding vectors in the featuremask

%Run Gabor Filtering 
gabors = apply_gabor_wavelet(I,0);

%normalize intensities
Inorm = (I-mean2(I))./std(I(:));


[h,w]=size(I);
datafeatures = [];
vector = zeros(1,1:size(gabors,3)+1);

for i= 1:w
    for j= 1:h
        if featuremask(j,i) ~= 1
            index = (i-1)*h+j;
            vector(index,1:size(gabors,3)) = gabors(i,j,:);
            vector(index,size(gabors,3)+1) = Inorm(i,j);
            datafeatures = [datafeatures; vector];
        end
    end
end

clear gabors

end

