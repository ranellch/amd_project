function [img1re] = match_sizing(img1, minx, miny)
    if(size(img1, 1) ~= miny || size(img1, 2) ~= minx)
        %Get the transform factor for the first image
        imgcorr1 = find_factor(img1, minx, miny);
        img1y = int32(size(img1, 1) * imgcorr1);
        img1x = int32(size(img1, 2) * imgcorr1);

        %Resize these images for both axes where the vertical is the reference
        img1re = imresize(img1, [img1y, img1x]);

        %Add padding to the images so that they are now the same
        img1re = pad_to_size(img1re, minx, miny);

        if(size(img1re, 1) ~= miny || size(img2re, 2) ~= minx)
            error('match_sizing did not work!');
        end
    else
        img1re = img1;
    end
end

function [img1] = pad_to_size(img1, minx, miny)
    %Get the dimensions of the input img1
    img1y = size(img1, 1);
    img1x = size(img1, 2);
    
    %Pad out y axis if neccessary
    if(img1y < miny)
        diff = miny - img1y;
        img1 = padarray(img1, [diff, 0], 0, 'post');
    end
    
    %Pad out x axis if neccessary
    if(img1x < minx)
        diff = minx - img1x;
        img1 = padarray(img1, [0, diff], 0, 'post');
    end
end

function [imgcorr] = find_factor(img, minx, miny)
    %Find the factor of the largest edge to make it the same size at the
    %minx of miny
    if(size(img,1) >= size(img,2))
        imgcorr = miny / size(img, 1);
    else
        imgcorr = minx / size(img, 2);
    end
end
