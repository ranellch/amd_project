function [outfile] = vessel_detection(img, optic_x, optic_y, macula_x, macula_y)
	original = rgb2gray(img);
    
    %Get the distance between optic disk and macula 
	distance = sqrt(power(optic_x - macula_x, 2) + power(optic_y - macula_y, 2));
	a = distance * .7;
	b = distance;

	%Run Gaussian filter
	G_para = fspecial('gaussian',[5 5], 1.2);
	g_filter = imfilter(original, G_para, 'same');

	%Run closure and subtrace that from the original image
	close_filter = imclose(g_filter, strel('square', 30));
	out = imsubtract(close_filter, g_filter);

	%Get the mean value of the grayscale
	mean_val = double(0);
	count = 0;
	for y = 1:size(out,1)
		for x = 1:size(out,2)
			mean_val = mean_val + double(out(y, x));
			count = count + 1;
		end
	end
	mean_val = mean_val / count;

	%Calculate the standard deviation for the distribution of gray sacle values
	variance = double(0);
	for y = 1:size(out,1)
		for x = 1:size(out,2)
			variance = variance + power((mean_val - double(out(y, x))), 2);
		end
	end
	stddev = sqrt(variance / count);

    %From the mean and std dev calculate the threshold as one stddev
	threshold = mean_val + stddev;

	%Threshold this badboy
	for x=1:size(out,2)
		for y = 1:size(out,1)
            %Get the x and y distance from the macula that this point it
			xdiff = abs(double(x) - macula_x);
			ydiff = abs(double(y) - macula_y);

			%Calculate the distance from the macula the current point 
			distance = sqrt(power(xdiff, 2) + power(ydiff, 2));

			%Get the theta of the point from the macula
			theta = 1.0 / tan(ydiff / xdiff);
            
            %Calculate the ellipse distance at this angle
			distance_ellipse = (a*b) / sqrt(power(b * cos(theta),2) + power(a * sin(theta),2));	
	
			%If the distance is greater than the radius then it is outside the circle
			if distance >= distance_ellipse
				pixel = out(y, x);
				if(pixel < threshold)
					out(y, x) = 0;
				else
					out(y, x) = 255;
				end
			else
				out(y, x) = 0;
			end
		end
    end
    
	%Use open morphological filtering
    out = bwmorph(out, 'close', 1);
	out = bwmorph(out, 'bridge', Inf);

	outfile = out;
end


