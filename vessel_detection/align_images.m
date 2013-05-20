function [aligned1, aligned2] = align_images(img1, img2)
	original = imread(img1);
	distorted = imread(img2);

	ptsOriginal  = detectSURFFeatures(original);
	ptsDistorted = detectSURFFeatures(distorted);

	[featuresIn   validPtsIn] = extractFeatures(original,  ptsOriginal);
	[featuresOut validPtsOut] = extractFeatures(distorted, ptsDistorted);

	index_pairs = matchFeatures(featuresIn, featuresOut);

	matchedOriginal  = validPtsIn(index_pairs(:,1));
	matchedDistorted = validPtsOut(index_pairs(:,2));

	%Initialize the geometric transform
	geoTransformEst = vision.GeometricTransformEstimator;
	geoTransformEst.Transform = 'Affine';
	geoTransformEst.NumRandomSamplingsMethod = 'Desired confidence';
	geoTransformEst.MaximumRandomSamples = 500;
	geoTransformEst.DesiredConfidence = 99.8;

	%[tform_matrix inlierIdx] = step(geoTransformEst, matchedDistorted.Location, matchedOriginal.Location);
	points1 = find_skel_intersection(original);
	points2 = find_skel_intersection(distorted);

	matched_f = matchFeatures(points1, points2);
	match_forig = points1(matched_f(:,1));
	match_fdis = points2(matched_f(:,2));
	
	%Find the minimum of the two arrays
	count = size(points1, 1);
	if count > size(points2, 1)
		count = size(points2, 1);
	end
	count_part = int32(count * .8);

	%Get two list of random indicies to use
	random1 = randsample(count, count_part);
	random2 = randsample(count, count_part);

	%Build the Mx2 matix used to insert into geomteric transform
	pts1 = zeros(count_part, 2);
	for line=1:count_part
		pts1(line, 1) = points1(random1(line), 1);
		pts1(line, 2) = points1(random1(line), 2);
		pts2(line, 1) = points2(random2(line), 1);
		pts2(line, 2) = points2(random2(line), 2);
	end

	[tform_matrix inlierIdx] = step(geoTransformEst, pts1, pts2);

	agt = vision.GeometricTransformer;
	Ir = step(agt, im2double(distorted), tform_matrix);
	figure; imshow(Ir); title('Recovered image');

	tform_matrix = cat(2,tform_matrix,[0 0 1]');

	Tinv  = inv(tform_matrix);
	ss = Tinv(2,1);
	sc = Tinv(1,1);

	scale_recovered = sqrt(ss*ss + sc*sc);
	theta_recovered = atan2(ss,sc)*180/pi;

	outfile = strcat(num2str(scale_recovered), ',', num2str(theta_recovered));
	disp(outfile);
end
