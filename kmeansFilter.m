function [imgout] = kmeansFilter(flnm,k)
%Required: flnm is an image file, k is the number of clusters
%Effect: Returns a filtered image with k different pixel clusters created
%using kmeans
    
    jpg = imread(flnm);    
    jpg = rgb2gray(jpg);
    
    %subplot(1,2,1); 
    %imshow(jpg); title('Original Image');% show original image
    
    sizeImage= size(jpg);
    sizeL= sizeImage(1)*sizeImage(2);
    allPixels =zeros(sizeL,1);
    for i= 1:sizeImage(1)
        for j= 1:sizeImage(2);
            index= (i-1)*sizeImage(2)+j;
            allPixels(index) = jpg(i,j);
        end
    end
    imgout = jpg;
    [idx, ctrs] = kmeans(allPixels,k);
    ctrs = round(ctrs);
    for i = 1:sizeImage(1)
        for j = 1:sizeImage(2);
            index = (i-1)*sizeImage(2)+j;
            imgout(i,j)= ctrs(idx(index));
        end
    end
     
    %subplot(1,2,2);
    %imshow(imgout); title('Filtered Image'); % show result
    
