function [ cropped_img ] = crop_footer( img )
% Removes footer from grayscale FAF image matrices 

i = floor(size(img,1)/2); %start at middle of image 

while i < size(img,1)
    if ~any(img(i+1,:)) % look for any non zero elements in a row
        break
    end
    i = i + 1;
end

cropped_img = imcrop(img, [0, 0, size(img,2), i]);
end

