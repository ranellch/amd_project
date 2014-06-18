function [imgout] = Seg(img)
    ratio = 2;
    kernelsize = 2;
    maxdist = 50;
    imgout = vl_quickseg(img, ratio, kernelsize, maxdist);
    figure, imshow(imgout);
end
