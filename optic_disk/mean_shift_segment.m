function [shifted_img] = mean_shift_segment(img)
%Make sure to include the vlfeat library
run('vlfeat/toolbox/vl_setup');
addpath('../intensity normalization');

%Make the image a grayscale if not currently a gray scale img
if size(img, 3) ~= 1
    img = rgb2gray(img);
end

%Smooth out the illumination
%img = smooth_illum_extracontrast(img);

%Run the mean shift algorithm
ratio = 0.75;
kernelsize = 2;
maxdist = 50;
mean_shift = vl_quickseg(img, ratio, kernelsize, maxdist);

%Get the shifted img
shifted_img = mean_shift;

end
