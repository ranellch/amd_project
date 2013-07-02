function [next_img] = prepare_image(img, transform_type)
	%Apply transform to the image
 	if(strcmpi(transform_type, 'invert') == 1)
        disp('prepare_image: imcomplement');
		next_img = imcomplement(img);
    else
        disp('prepare_image: none');
		next_img = img;
    end
end