function [data] = compare_maculas()
	%Read in the original image
	color = imread('1.jpg');
	original = rgb2gray(color);

	%Run Gaussian filter
	G_para = fspecial('gaussian',[5 5], 1.2);
	g_filter = imfilter(original, G_para, 'same');

	%Run closure
	close_filter = imclose(g_filter, strel('square', 31));
	tophat = imsubtract(close_filter, g_filter);

	%Set either value to zero or to max
	mean_val = mean(mean(tophat)) * 3;
	for x = 1:size(tophat,1)
		for y = 1:size(tophat,2)
			pixel = tophat(x, y);
			if(pixel < mean_val)
				tophat(x, y) = 0;
			else
				tophat(x, y) = 255;
			end
		end
	end

	%Use open morphological filtering
	openmorph = imopen(tophat, strel('square', 3));

	%Calculate the skeleton on the image
	skel = bwmorph(openmorph, 'skel', Inf);
	
	%Save to disk
	imwrite(skel, 'test.jpg');
end

	
