function [img1re, img2re] = match_sizing(img1, img2)
    %Find the smallest images axeses of the original
    miny = min_axis(img1, img2, 1);
    minx = min_axis(img1, img2, 2);
    
    %Find which axis to base it upon around
    largeaxis = 'y';
    if miny < minx
        largeaxis = 'x';
    end
    
    %Get the transform factor for the first image
    imgcorr1 = find_factor(img1, largeaxis, minx, miny);
    img1y = int32(size(img1, 1) * imgcorr1);
    img1x = int32(size(img1, 2) * imgcorr1);
    
    %Get the transform factor for the second image
    imgcorr2 = find_factor(img2, largeaxis, minx, miny);
    img2y = int32(size(img2, 1) * imgcorr2);
    img2x = int32(size(img2, 2) * imgcorr2);
    
    %Resize these images for both axes
    img1re = imresize(img1, [img1y, img1x]);
    img2re = imresize(img2, [img2y, img2x]);
    
    %Crop size to make them match
    [img1final, img2final] = crop_size(img1re, img2re);
    img1re = img1final;
    img2re = img2final;
end

function [img1f, img2f] = crop_size(img1, img2)
    %Find the smallest thing to do
    smallx = min_axis(img1, img2, 2);
    smally = min_axis(img1, img2, 1);
    
    %Crop the image
    img1f = imcrop(img1, [0,0,smally, smallx]);
    img2f = imcrop(img2, [0,0,smally, smallx]);
end

function [imgcorr] = find_factor(img, largeaxis, minx, miny)
    %Find transformation factor from original minx or minx based upon largeaxis
    imgcorr = 0;
    if strcmp(largeaxis, 'x') == 1
        imgcorr = minx / size(img, 2);
    elseif strcmp(largeaxis, 'y') == 1
        imgcorr = miny / size(img, 1);
    end
end

function [out] = min_axis(img1, img2, dim)
    %Find the minimum between two images for individual dimensions
    out = size(img1, dim);
    if(size(img2, dim) < out)
       out =  size(img2, dim);
    end
end
