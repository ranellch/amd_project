function [bimg] = vessel_detection_new(I)
    %Allocate the output image to sum up morpholocigcal filters
    bimg = zeros(size(I,1), size(I,2));

    %Combine all the images into a final image using each structuring element
    M = 8;
    length_element = 5;
    wedge = 180 / M;
    for i=1:M
        line = strel('line', length_element, i * wedge);
        bimg = add_img(apply_morph(Y, line), M, bimg);
    end

    figure(1);
    imshow(bimg);
end