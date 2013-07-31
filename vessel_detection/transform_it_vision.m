function [theta, scale, translation, tform] = transform_it_vision(pointsA, pointsB)
    %Estimate the transform and set the parameters
    gte = vision.GeometricTransformEstimator;
    gte.Transform = 'Nonreflective similarity';
    
    %Get the tform matrix
    tform = step(gte, pointsB, pointsA);
    
    %Get the affine matrix
    R = tform(1:2,1:2);
    
    %Get the slace, theta, and translation of the affine matrix
    theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
    scale = mean(R([1 4])/cos(theta));
    translation = tform(3, 1:2);
end
