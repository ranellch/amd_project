function [aligned1, aligned2] = align_images(img1, img2)
	original = rgb2gray(img1);
	distorted = rgb2gray(img2);
    
	ptsOriginal  = detectSURFFeatures(original);
	ptsDistorted = detectSURFFeatures(distorted);
    
    disp(ptsOriginal);
    
    %Find features from feature points
	[featuresIn   validPtsIn] = extractFeatures(original,  ptsOriginal);
	[featuresOut validPtsOut] = extractFeatures(distorted, ptsDistorted);

    
    
    %Find matches between the two iamges
	index_pairs = matchFeatures(featuresIn, featuresOut, 'Metric', 'SAD', 'MatchThreshold', 5);
    
    %Get the coordinates of the points
	matchedOriginal  = validPtsIn(index_pairs(:,1));
	matchedDistorted = validPtsOut(index_pairs(:,2));
    
    figure(1); imshow(original); hold on;
    plot(ptsOriginal.selectStrongest(700));
    title('Thirty strongest SURF features in I1');

    figure(2); imshow(distorted); hold on;
    plot(ptsDistorted.selectStrongest(700));
    title('Thirty strongest SURF features in I1');
    
    %Estimate the fundemental matrix
    [fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
                           matchedOriginal.Location, matchedDistorted.Location, ...
                           'Method', 'RANSAC', 'NumTrials', 10000,...
                           'DistanceThreshold', 0.1, 'Confidence', 99.99);
                       
    if status ~= 0
        error('Not enough matching points');
    elseif isEpipoleInImage(fMatrix, size(original)) || isEpipoleInImage(fMatrix, size(distorted))
        error(['The epipoles are inside the images. You may need to '...
            'inspect and improve the quality of detected features ',...
            'and/or improve the quality of your images.']);
    end
    
    inlierPoints1 = matchedOriginal(epipolarInliers, :);
    inlierPoints2 = matchedDistorted(epipolarInliers, :);
    
    [t1, t2] = estimateUncalibratedRectification(fMatrix,...
                                  inlierPoints1.Location, inlierPoints2.Location, size(distorted));
    tform1 = projective2d(t1);
    tform2 = projective2d(t2);
    
    I1Rect = imwarp(I1, tform1, 'OutputView', imref2d(size(I1)));
    I2Rect = imwarp(I2, tform2, 'OutputView', imref2d(size(I2)));
    
    imshow(I1Rect);
    imshow(I2Rect);
end
