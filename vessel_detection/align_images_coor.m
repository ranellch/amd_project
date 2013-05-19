function [result] = align_images_coor(img1, img2)
	image1 = double(imread(img1))/256;
	image2 = double(imread(img2))/256;
	
	cc = correlCorresp('image1', image1, 'image2', image2, 'printProgress', 100);
	cc.advanceFeatures = true; 
	cc.relThresh = 0.2;
	cc.matchTol = 1;

	%cc = cc.findCorresps;
	%correspDisplay(cc.corresps, image1);

	points1 = find_skel_intersection(image1);
	points2 = find_skel_intersection(image2);

	scatterplot(points1);
	scatterplot(points2);
end
