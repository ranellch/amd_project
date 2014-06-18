function [img] = im2unitRange(img)
%img=IM2UNITRANGE(img)
%   Detailed explanation goes here

img = img-min(img(:));
img = img / max(img(:));

end

