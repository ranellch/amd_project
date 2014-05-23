function [ cropped_img ] = crop_footer( img )
% Removes footer from grayscale FAF image matrices 

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
i = i - 2; %-1 for extra increment, -1 to exclude first row of 0s
cropped_img = imcrop(img, [0, 0, size(img,2), i]);
end

