function [r,c,v] = corrpeak(i, m, n, tol)
%CORRPEAK  Find peak of correlation.
%   [R, C, V] = CORRPEAK(I, M, N, TOL)  Return the R,C coordinates in I of
%   the peak of its correlation with M, together with the peak correlation
%   value V.  TOL is the relative accuracy with which M is represented in
%   the correlation. The centre point of M is taken as its (0,0) coordinate
%   point, so if M has even size R and/or C may not be a whole number.
%
%   N is a normalisation matrix - the correlation result is divided by it
%   before the peak is found. It needs to be the same size as a 'valid'
%   convolution of i with m.
%
%   TOL may be omitted and defaults to 0. Both TOL and N may be omitted:
%   TOL then defaults to 0 and no normalisation is applied. If N is [] then
%   likewise no normalisation is used.

% Copyright David Young 2010

if nargin < 4; tol = 0; end
if nargin < 3; n = []; end

m = rot90(m, 2);        % convert to convolution
cc = convolve2(i, m, 'valid', tol);
if ~isempty(n); cc = cc ./ n; end
[v,r,c] = max2(cc);

% Allow for offset caused by taking valid region
offsets = (size(m)-1)/2;
r = r + offsets(1);
c = c + offsets(2);

end
