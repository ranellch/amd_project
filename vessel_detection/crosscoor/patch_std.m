function y = patch_std(varargin)
%PATCH_STD  Sliding standard deviation.
%   Y = PATCH_STD(X, PSIZE)
%   Y = PATCH_STD(X, PSIZE, SHAPE)
%   See PATCH_VAR for details.
%
% See also PATCH_VAR

% Copyright David Young 2010

y = sqrt(patch_var(varargin{:}));

end
