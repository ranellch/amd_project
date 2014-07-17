function [img] = zero_m_unit_std(img)
%ZERO_M_ONE_STD Summary of this function goes here
%   This function normalizes data to zero mean and unit standard deviation
%   while excluding NaN entries

img = double(img);

img = img - mean( img(~isnan(img)) );
img = img / std( img(~isnan(img)) );

end

