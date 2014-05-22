function [img1, img2] = normalizePixelSize(img1, info1, img2, info2)
%[img1, img2] = NORMALIZEPIXELSIZE(img1, info1, img2, info2)
%   Normalizes pixel size of two images to that of the high-precision image

scale1 = info1.ScaleX;
if scale1 ~= info1.ScaleY
    error('Pixels in img1 are not squares!');
end

scale2 = info2.ScaleY;
if scale2 ~= info2.ScaleY
    error('Pixels in img2 are not squares!');
end

if scale1==scale2
    return;
elseif scale1>scale2
    img1 = imresize(img1, scale1/scale2);
else
    img2 = imresize(img2, scale2/scale1);
end

end

