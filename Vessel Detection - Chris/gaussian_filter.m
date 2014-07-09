function [iout] = gaussian_filter(img)
    h = fspecial('gaussian', [3 3], .5);
    iout = imfilter(img, h, 'symmetric');
end
