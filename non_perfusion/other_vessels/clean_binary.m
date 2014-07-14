function [ binary_out ] = clean_binary( binary_img, debug )

%Remove the border because it tends to not be that clean
border_remove = 10;
for y=1:size(binary_img,1)
    for x=1:size(binary_img, 2)
        if(y < border_remove || x < border_remove || ...
           y > (size(binary_img, 1) - border_remove) || ...
           x > (size(binary_img, 2) - border_remove))
            binary_img(y,x) = 0;
        end
    end
end

%Apply morolgical operation to smooth out the edges
binary_img = bwmorph(binary_img, 'majority');

%Apply morphological operations to clean up the small stuff
binary_out = bwareaopen(binary_img,60);

if(debug == 1)
    figure(3), imshow(binary_out);
end



end

