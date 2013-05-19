function [result] = align_images_vl(img1, img2)
	addpath('vlfeat');

	I1 = imread(img1);
	%I1 = single(I1);
	%[f1,d1] = vl_sift(I1);
	
	I2 = imread(img2);
	%I2 = single(I2);
	%[f2,d2] = vl_sift(I2);

	%[matches, scores] = vl_ubcmatch(d1, d2);

	rect_i1 = [0 0 400 400];
	rect_i2 = [20 20 200 200];
	i1tl = imcrop(I1, rect_i1);
	i2tl = imcrop(I2, rect_i2);

	c = normxcorr2(i2tl, i1tl);

	figure, surf(c), shading flat;

	[max_c, imax] = max(abs(c(:)));
	[ypeak, xpeak] = ind2sub(size(c),imax(1));
	corr_offset = [(xpeak-size(i2tl,2)) 
			(ypeak-size(i2tl,1))];

	% relative offset of position of subimages
	rect_offset = [(rect_i1(1)-rect_i2(1))
			(rect_i1(2)-rect_i2(2))];

	% total offset
	offset = corr_offset + rect_offset;
	xoffset = offset(1);
	yoffset = offset(2);

	xbegin = int32(round(xoffset+1));
	xend   = int32(round(xoffset+ size(i1tl,2)));
	ybegin = int32(round(yoffset+1));
	yend   = int32(round(yoffset+size(i1tl,1)));

	recovered_i1 = zeros(size(I1, 1), size(I1, 2));
	for x=1:size(i1tl, 2)
		for y=1:size(i1tl, 1)
			if(y + yoffset > 0 && x + xoffset > 0)
				recovered_i1(y + yoffset, x + xoffset) = i1tl(y, x);
			end
		end
	end

	imshow(recovered_i1);

	disp(xbegin);
	disp(xend);
	disp(ybegin);
	disp(yend);
end
