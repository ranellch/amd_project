function [img] = shadeCorrection(img, featuresize)
%img = SHADECORRECTION(img, featuresize)
%   Detailed explanation goes here

bkg = medfilt2(img, [featuresize featuresize]);
img = img - bkg;
img = im2unitRange(img);

end

