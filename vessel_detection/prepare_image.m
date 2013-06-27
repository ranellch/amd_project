function [next_img] = prepare_image(img, transform_type)
	%Apply transform to the image
 	if(strcmpi(transform_type, 'invert') == 0)
		next_img = imcomplement(img);
	else
		next_img = img;
    end
end