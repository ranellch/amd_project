function [bimg] = vessel_detection_new(I)
    
    addpath('..');
    
    %Remove the footer if necessary
    %I = crop_footer(I);
    
    %Allocate the output image to sum up morpholocigcal filters
    bimg = zeros(size(I,1), size(I,2));

    %Combine all the images into a final image using each structuring element
    M = 8;
    length_element = 5;
    wedge = 180 / M;
    for i=1:M
        line = strel('line', length_element, i * wedge);
        bimg = add_img(apply_morph(I, line), M, bimg);
    end

    figure(1);
    imshow(bimg);
end

function [finalimg] = add_img(inputimg, M, finalimg)
    if size(inputimg, 1) == size(finalimg, 1) && ...
       size(inputimg, 2) == size(finalimg, 2)
        for y=1:size(inputimg, 1)
            for x=1:size(inputimg, 2)
                finalimg(y, x) = finalimg(y, x) + (inputimg(y, x) / M);
            end
        end
    else
        disp('Incorrect SIZE');
    end
end

function [out] = apply_morph(img, strelement)
    newimg = imclose(img, strelement);
    newimg = imopen(newimg, strelement);
    
    newimg1 = imdilate(newimg, strelement);
    newimg2 = imerode(newimg, strelement);
    
    out = imsubtract(newimg1, newimg2);
    imshow(out);
end