function [theta, scale, translation, tform] = transform_it(pointsA, pointsB)
    %Estimate the transform and set the parameters
    gte = vision.GeometricTransformEstimator;
    gte.Transform = 'affine';
    gte.ExcludeOutliers = true;
    gte.Method = 'Random Sample Consensus (RANSAC)';
    gte.RefineTransformMatrix = true;
    
    %Get the tform matrix
    [tform] = step(gte, pointsB, pointsA);
    
    %Get the affine matrix
    H = tform;
    R = H(1:2,1:2);
    
    %Get the slace, theta, and translation of the affine matrix
    theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
    scale = mean(R([1 4])/cos(theta));
    translation = H(3, 1:2);
end
