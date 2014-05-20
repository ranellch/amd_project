function [imgout] = kmeansFilter(I,k)
%Required: I is an image matrix, k is the number of clusters
%Effect: Returns a filtered image with k different pixel clusters created
%using kmeans
       
    I = rgb2gray(I);
    
    %subplot(1,2,1); 
    %imshow(jpg); title('Original Image');% show original image
    
    sizeImage= size(I);
    sizeL= sizeImage(1)*sizeImage(2);
    allPixels =zeros(sizeL,1);
    for i= 1:sizeImage(1)
        for j= 1:sizeImage(2);
            index= (i-1)*sizeImage(2)+j;
            allPixels(index) = I(i,j);
        end
    end
    imgout = I;
    [idx, ctrs] = kmeans(allPixels,k, 'EmptyAction', 'singleton');
    ctrs = round(ctrs);
    for i = 1:sizeImage(1)
        for j = 1:sizeImage(2);
            index = (i-1)*sizeImage(2)+j;
            imgout(i,j)= ctrs(idx(index));
        end
    end
     
    %subplot(1,2,2);
    %imshow(imgout); title('Filtered Image'); % show result
    
