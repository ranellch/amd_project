function [img1re, img2re] = match_sizing(img1, img2)
    %Find the smallest images axeses of the original
    miny = min_axis(img1, img2, 1);
    minx = min_axis(img1, img2, 2);
    
    %Choose which axis to base the transform upon
    largeaxis = 'x';
    
    %Get the transform factor for the first image
    imgcorr1 = find_factor(img1, largeaxis, minx, miny);
    img1y = int32(size(img1, 1) * imgcorr1);
    img1x = int32(size(img1, 2) * imgcorr1);
    
    %Get the transform factor for the second image
    imgcorr2 = find_factor(img2, largeaxis, minx, miny);
    img2y = int32(size(img2, 1) * imgcorr2);
    %img2x = int32(size(img2, 2) * imgcorr2);
    
    %Resize these images for both axes where the vertical is the reference
    img1re = imresize(img1, [img1y, img1x]);
    img2re = imresize(img2, [img2y, img1x]);
        
    %Add padding to the images so that they are now the same
    [img1re, img2re] = pad_to_size(img1re, img2re);
end

function [img1, img2] = pad_to_size(img1, img2)
    %Get the dimensions of the input img1
    img1y = size(img1, 1);
    img1x = size(img1, 2);
    
    %Get the dimensions of the input img2
    img2y = size(img2, 1);
    img2x = size(img2, 2);
    
    to_pad = 'none';
    larger_val = 0;
    which_img = '2';
    
    if(img1y == img2y && img1x ~= img2x)
        to_pad = 'x';
        larger_val = img1x - img2x;
        if(img1x < img2x)
            larger_val = img2x - img1x;
            which_img = '1';
        end
    elseif(img1x == img2x && img1y ~= img2y)
        to_pad = 'y';
        larger_val = img1y - img2y;
        if(img1y < img2y)
            larger_val = img2y - img1y;
            which_img = '1';
        end
    elseif(img1x == img2x && img1y == img2y)
        return;
    else
        disp('Neither X nor Y axis are the same, pad_to_size');
    end
    
    %Checkout which image to pad
    if(strcmp(which_img, '1') == 1)
        img1 = pad_array(img1, to_pad, larger_val);
    else
        img2 = pad_array(img2, to_pad, larger_val);
    end
end

function [outval] = pad_array(img, side, pad)
    %Create a new temporary matrix that will hold the original image in addition to the new padding
    if(strcmp(side, 'x') == 1)
        outval = uint8(zeros(size(img, 1), size(img,2) + pad, size(img, 3)));
    elseif(strcmp(side, 'y') == 1)
        outval = uint8(zeros(size(img, 1) + pad, size(img,2), size(img, 3)));
    else
        outval = img;
        msgbox('Error: pad_array in input of side variable');
        return;
    end
    
    %Copy in the portion of the image that was part of the original
    for y=1:size(img, 1)
        for x=1:size(img, 2)
            for pixel=1:size(img,3)
                outval(y, x, pixel) = img(y, x, pixel);
            end
        end
    end
end

function [imgcorr] = find_factor(img, largeaxis, minx, miny)
    imgcorr = 0;
    if strcmp(largeaxis, 'x') == 1
        imgcorr = minx / size(img, 2);
    elseif strcmp(largeaxis, 'y') == 1
        imgcorr = miny / size(img, 1);
    end
end
