function [r,c] = varPeaks(im, patchsize, relthresh)
%varPeaks  Get set of distinctive points in image
%    [R,C] = varPeaks(IM, PATCHSIZE, RELTHRESH) returns the row and column
%    coords of a set of points in the image IM which can be used as a set
%    of features for matching.
%
%    Features are local maxima of local variance. The variance for each
%    square patch of size PATCHSIZExPATCHSIZE is found. Features are
%    returned for local maxima of this measure where it exceeds RELTHRESH *
%    (the maximum local variance).
% 
%    PATCHSIZE should normally be odd. RELTHRESH should be in the range 0
%    to 1; higher values mean fewer points are returned.

% Copyright David Young 2010

vars = patch_var(im, patchsize);
[r,c,v] = findpeaks(vars);
keep = v > relthresh * max(v);
% select high features and restore indexing for original image
hsize = (patchsize-1) / 2;
r = r(keep) + hsize;
c = c(keep) + hsize;

end
