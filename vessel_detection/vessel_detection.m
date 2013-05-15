function [data] = compare_maculas()
	%Read in the original image
	img = '1.jpg';
	color = imread(img);
	original = rgb2gray(color);
	optic_x = 0;
	optic_y = 0;
	macula_x = 0;
	macula_y = 0;

	%Open the XML document and parse
	xDoc= xmlread('1.xml');
	xRoot = xDoc.getDocumentElement;

	%Get the image element from the XML file
	images = xRoot.getChildNodes;
	image = images.getChildNodes;

	%Parse out the values from XML file
	optic_x = str2num(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent);
	optic_y = str2num(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent);
	macula_x = str2num(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent);
	macula_y = str2num(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent);

	%Get the distance between optic disk and macula 
	radius = sqrt(power(optic_x - macula_x, 2) + power(optic_y - macula_y, 2)) * .8;

	disp(strcat(img, ' - macula_x: ', int2str(macula_x), ' macula_y: ', int2str(macula_y), ' - radius: ', num2str(radius)));

	%Run Gaussian filter
	G_para = fspecial('gaussian',[5 5], 1.2);
	g_filter = imfilter(original, G_para, 'same');

	%Run closure
	close_filter = imclose(g_filter, strel('square', 31));
	tophat = imsubtract(close_filter, g_filter);

	%Get the mean value of the grayscale
	mean_val = double(0);
	count = 0;
	for y = 1:size(tophat,1)
		for x = 1:size(tophat,2)
			mean_val = mean_val + double(tophat(y, x));
			count = count + 1;
		end
	end
	mean_val = mean_val / count;

	%Calculate the standard deviation for the distribution of gray sacle values
	variance = double(0);
	for y = 1:size(tophat,1)
		for x = 1:size(tophat,2)
			variance = variance + power((mean_val - double(tophat(y, x))), 2);
		end
	end
	stddev = sqrt(variance / count);

	disp(strcat('mean: ', num2str(mean_val), ' stdev: ', num2str(stddev)));

	threshold = mean_val + stddev;

	%Threshold this badboy
	for x = 1:size(tophat,2)
		for y = 1:size(tophat,1)
			%Calculate the distnace from the macula the current point 
			distance = sqrt(power(double(x) - macula_x, 2) + power(double(y) - macula_y, 2));
			
			%If the distance is greater than the radius then it is outside the circle
			if distance >= radius
				pixel = tophat(y, x);
				if(pixel < threshold)
					tophat(y, x) = 0;
				else
					tophat(y, x) = 255;
				end
			else
				tophat(y, x) = 0;
			end
		end
	end

	%imwrite(tophat, 'test.jpg');

	%Use open morphological filtering
	openmorph = imopen(tophat, strel('square', 3));

	%Calculate the skeleton on the image
	skel = bwmorph(openmorph, 'skel', Inf);
	
	%Save to disk
	imwrite(skel, 'test.jpg');
end

	
