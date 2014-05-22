function [DC] = DiceCoefficientFromBinaryMasks(mask1, mask2)
%DC=DICECOEFFICIENTFROMBINARYMASKS(mask1, mask2)
%   It takes into two binary masks of the same dimension and returns Dice 
%   coefficient for 1-valued regions in the masks.
%   NOTE: Dice coefficient is sensitive to very small area of 1-valued
%   regions.

intersection = mask1 & mask2;
summation = sum(mask1(:)) + sum(mask2(:));

DC = 2*sum(intersection(:)) / summation;

end

