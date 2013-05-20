function [result] = align_images_vl(img1, img2)
	addpath('vlfeat');

	I1 = imread(img1);
	I1B = im2bw(I1, .3);
	imwrite(I1B, 'test.jpg');
	corners = find_crossings(I1);

	%I1 = single(I1);
	%[f1,d1] = vl_sift(I1);
	
	I2 = imread(img2);
	%I2 = single(I2);
	%[f2,d2] = vl_sift(I2);

	%[matches, scores] = vl_ubcmatch(d1, d2);

	[optimizer, metric] = imregconfig('multimodal');

	optimizer.InitialRadius = 0.009;
	optimizer.Epsilon = 1.5e-4;
	optimizer.GrowthFactor = 1.01;
	optimizer.MaximumIterations = 300;

	%movingRegistered = imregister(I2, I1, 'affine', optimizer, metric);
end

function [points] = find_crossings(I)
	cornerDetector = vision.CornerDetector
	LOC = step(cornerDetector,I)
	points = LOC;
end
