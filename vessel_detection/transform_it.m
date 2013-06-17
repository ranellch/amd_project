function [out] = transform_it(pointsA, pointsB)
    %Get the transform class
    %H = vision.GeometricTransformEstimator;
    
    %Estimate the transform
    [tform] = estimateGeometricTransform(pointsA, pointsB, 'affine');
    
    %Get the affine matrix
    H = tform.T;
    R = H(1:2,1:2);
    
    %Get the slace, theta, and translation of the affine matrix
    theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
    scale = mean(R([1 4])/cos(theta));
    translation = H(3, 1:2);
    
    %Transform the image
    hgt = vision.GeometricTransformer;
    output = step(hgt, input, tform);
    
    imgBold = imwarp(image2, tform, 'OutputView', imref2d(size(image2)));
end
