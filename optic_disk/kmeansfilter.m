function [imgout] = kmeansfilter(flnm,k)
%Required: flnm is an image file, k is the number of clusters
%Effect: Returns a filtered image with k different pixel clusters created
%using kmeans
     
sizeImage = size(flnm);

sizeL= sizeImage(1)*sizeImage(2);
allPixels =zeros(sizeL,1);
for i= 1:sizeImage(1)
	for j= 1:sizeImage(2);
		index= (i-1)*sizeImage(2)+j;
		allPixels(index) = flnm(i,j);
	end
end

imgout = flnm;

[idx, ctrs] = kmeans(allPixels,k);
ctrs = round(ctrs);

for i = 1:sizeImage(1)
	for j = 1:sizeImage(2);
		index = (i-1)*sizeImage(2)+j;
		imgout(i,j)= ctrs(idx(index));
	end
end
