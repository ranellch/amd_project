function [tform] = imregSurfRANSAC(distorted, original)
%[tform] = IMREGSURFRANSAC(distorted, original)
%   Detailed explanation goes here

% Detect features in both images.
ptsOriginal  = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);

% Extract feature descriptors.
[featuresOriginal,  validPtsOriginal]  = extractFeatures(original,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(distorted, ptsDistorted);

% Match features by using their descriptors.
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

% Retrieve locations of corresponding points for each image.
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

tform = estimateGeometricTransform(matchedDistorted, matchedOriginal, 'similarity');

end

