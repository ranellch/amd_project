function [ cropped_img ] = crop_footer( img )
% Removes info footer from grayscale FAF / FA image matrices 

i = round(size(img, 1) / 2); % start at middle
cont = 1;

while cont == 1
    %Check for any non zero elements in a row
    cont = any(img(i,:));
    i = i + 1;
    
    %Check to see if at end of img
    if i > size(img,1)
       cont = 0;
    end
end

cropped_img = imcrop(img, [1, 1, size(img,2), (i-1)]);
end

