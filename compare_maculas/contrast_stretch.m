function [ G ] = contrast_stretch( F, varargin )
%G = contrast_stretch(F) performs contrast stretching on image F
%   using the expression 1./(1 + M./(F+eps)).^E).  Parameter M must be in
%   the range[0,1].  The default value for M is mean2(im2double(img)), and the
%   default value for E is 4.  Output image is of class unint8.
%
%   Other acceptable syntax:
%   G = contrast_streth(F, E)
%   G = contrast_stretch(F,M,E)

F = im2double(F);

if isempty(varargin)
    % use defaults
    m = mean2(F);
    E = 4.0;
elseif length(varargin) == 1
    m = mean2(F);
    E = varargin{1};
elseif length(varargin) == 2
    m= varargin{1};
    E = varargin{2};
else error('Incorrect number of inputs')
end

G = 1./(1+(m./(F+eps)).^E);
G = im2uint8(mat2gray(G));

end

