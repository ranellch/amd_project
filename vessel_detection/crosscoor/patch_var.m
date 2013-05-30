function y = patch_var(x, psize, shape)
%PATCH_VAR  Sliding variance
%   Y = PATCH_VAR(X, PSIZE) returns a matrix Y each element of which is
%   the variance of a patch of X. X must be 2-D and contain at least one
%   patch. PSIZE gives the size of the patch: if it is a scalar than the
%   patch is PSIZE-by-PSIZE; otherwise PSIZE should be a 2-element
%   vector giving the numbers of rows and columns in the patch. Y will
%   be smaller than X as zero padding is not done: if size(X) is [nr,nc]
%   then size(Y) will be [nr-PSIZE(1)+1, nc-PSIZE(2)+1].
%
%   Y = PATCH_VAR(X, PSIZE, SHAPE) is the same except that SHAPE specifies
%   the boundary behaviour as for CONVOLVE2. For example, 'reflect' may be
%   used to cause Y to be the same size as X.

% Copyright David Young 2010

% This is very much more efficient (both in time and memory) than
% using COLFILT with VAR.

if nargin < 3
    shape = 'valid';
end

m = ones(psize);        % averaging mask
n = numel(m);

if strcmp(shape, 'valid')
    x = x - mean(x(:));     % improve stability if possible
end

a = convolve2(x, m, shape);
as = convolve2(x.*x, m, shape);

% Best to divide result not mask, as svd in convolve2 is
% sometimes slower if mask is not ones(!)
y = (as - (a.*a)/n )/n;

end
