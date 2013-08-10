function [next_img, matlab_func] = prepare_image(img, transform_type)
	%Apply transform to the image
 	if(strcmpi(transform_type, 'invert') == 1)
        matlab_func = 'imcomplement';
		next_img = imcomplement(img);
    else
        matlab_func = 'none';
		next_img = img;
    end
end