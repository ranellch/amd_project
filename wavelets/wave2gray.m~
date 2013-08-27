function w = wave2gray( c, s, varargin )
%WAVE2GRAY Display wavelet decomposition coefficients.
%   W = WAVE2GRAY(C, S, SCALE, BORDER) displays and returns a wavelet
%   coefficient image.
%
%   EXAMPLES:
%       wave2gray(c,s);                     Display w/ defaults
%       foo = wave2gray(c,s);               Display and return
%       foo = wave2gray(c, s, 4);           Magnify the details
%       foo = wave2gray(c, s, -4);          Magnify absolute values
%       foo = wave2gray(c, s, 1, 'append'); Keep border values
%
%   INPUTS/OUTPUTS:
%       [C, S] is a wavelet decomposition vector and bookkeeping matrix
%
%       SCALE                  Detail coefficient scaling
%       ----------------------------------------------------------------
%       1                      Maximum range (default)
%       2, 3...                Magnify default by the scale factor
%       -1, -2...              Magnify absolute values by abs(scale)
%
%       BORDER                 Border between wavelet decompositions
%       ----------------------------------------------------------------
%       'absorb'               Border replaces image (default)
%       'append'               Border increases width of image
%
%       Image sections represent (clockwise from top right): horizontal, diagonal, and vertical detail
%       coefficients.  The upper left section is the scale n approximation
%       of the original image 

%Check input args
narginchk(2,4);

if nargin == 2
    scale = 1; %Default scale
elseif nargin >= 3
    scale = varargin{1};
end
 
if nargin < 4
    border = 'absorb'; %Default border
elseif nargin == 4
    border = varargin{2};
end

if ~ismatrix(c) || (size(c,1) ~= 1)
    error('C must be a row vector');
end

if ~ismatrix(s) || ~isreal(s) || ~isnumeric(s) || (size(s,2) ~= 2)
    error('S must be a real, numeric, two column array');
end

elements = prod(s, 2);
if (length(c) < elements(end)) || ~(elements(1) + 3*sum(elements(2:end-1)) >= elements(end))
    error('[C S] must be a standard wavelet decomposition structure');
end

if (nargin > 2) && ~isreal(scale) || ~isnumeric(scale)
    error('SCALE must be a real numeric scalar');
end

if (nargin > 3) && ~ischar(border)
    error('BORDER must be character string');
end


%Scale coefficients and determine pad fill 
absflag = scale < 0;
scale = abs(scale);

[cd, w] = wavework('cut', 'a', c, s);
cdx = max(abs(cd(:))) / scale;
if absflag 
    cd = mat2gray(abs(cd), [0, cdx]); fill = 0;
else
    cd = mat2gray(cd, [-cdx, cdx]); fill = 0.5;
end

% Build gray image one decomposition at a time
for i = size(s,1) - 2:-1:1
    ws = size(w);
    
    h = wavework('copy', 'h', cd, s, i);
    pad = ws - size(h); frontporch = round(pad/2);
    h = padarray(h, frontporch, fill, 'pre');
    h = padarray(h, pad - frontporch, fill, 'post');
    v = wavework('copy', 'v', cd, s, i);
    pad = ws - size(v); frontporch = round(pad/2);
    v = padarray(v, frontporch, fill, 'pre');
    v = padarray(v, pad - frontporch, fill, 'post');
    d = wavework('copy', 'd', cd, s, i);
    pad = ws - size(d); frontporch = round(pad/2);
    d = padarray(d, frontporch, fill, 'pre');
    d = padarray(d, pad - frontporch, fill, 'post');
    % Add 1 pixel white border
    switch lower(border)
        case 'append'
            w = padarray(w, [1 1], 1, 'post');
            h = padarray(h, [1 0], 1, 'post');
            v = padarray(v, [0 1], 1, 'post');
        case 'absorb'
            w(:,end) = 1;   w(end,:) = 1;
            h(end,:) = 1;   v(:,end) = 1;
        otherwise
            error('Invalid BORDER type');
    end
    w = [w h; v d];  %Concatenate coefs
end

if nargout == 0 %Display result
    imshow(w);
end
            
end

