function [outfile] = vessel_detection(img)%, optic_x, optic_y, macula_x, macula_y)
	%Read in the original image
	img_val = regexp(img, '[.]', 'split');
	img_name = char(img_val(1));
    
    %Get the image and convert to graysacle
	original = (imread(img));
    
    %Remove the footer from the image
    original = crop_footer(original);
    
	%Get the distance between optic disk and macula 
	%distance = sqrt(power(optic_x - macula_x, 2) + power(optic_y - macula_y, 2));
	%a = distance * .7;
	%b = distance;

	%Run Gaussian filter
	g_filter = imfilter(original, fspecial('gaussian', [5 5], 1.2), 'same');

	%Run closure on the image
	close_filter = imclose(g_filter, strel('square', 3));
    
    %Run BTH operator
    bthval = imclose(close_filter, strel('square', 31));
	out = imsubtract(bthval, close_filter);
      
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
	threshold = mean_val + (stddev * .4);

	%Threshold this badboy
	for x=1:size(out,2)
		for y = 1:size(out,1)
            %Get the x and y distance from the macula that this point it
			%xdiff = abs(double(x) - macula_x);
			%ydiff = abs(double(y) - macula_y);

			%Calculate the distance from the macula the current point 
			%distance = sqrt(power(xdiff, 2) + power(ydiff, 2));

            %Calculate the ellipse distance at this angle
			%theta = 1.0 / tan(ydiff / xdiff);
            %distance_ellipse = (a*b) / sqrt(power(b * cos(theta),2) + power(a * sin(theta),2));	
	
			%if distance >= distance_ellipse
			if 1 == 1
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
    
    %Calculate the skeleton on the image
    out = bwareaopen(out, 20);
	out = bwmorph(out, 'bridge');
    out = bwmorph(out, 'thin', Inf);
    out = bwmorph(out, 'fill');
    out = bwmorph(out, 'spur');
    out = bwmorph(out, 'thin', Inf);
    
    out = bwareaopen(out, 20);
    
	%Save to disk
	output = strcat('vd_', img_name ,'.jpg');
	imwrite(out, output);
    
    outfile = output;
end


