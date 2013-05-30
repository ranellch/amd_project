function [r,c,v] = findpeaks(h, varargin)
%FINDPEAKS Finds the local maxima of an array.
%   [R,C,V] = FINDPEAKS(X) returns the row and column coordinates and the
%   values of the regional maxima of the 2-D array X. R(I), C(I) and V(I)
%   are respectively the row, column and value of the I'th regional
%   maximum.
%
%   [R,C,V] = FINDPEAKS(X, OPTIONS) gives additional control. OPTIONS is a
%   comma-separated list of parameter/value pairs, with the following
%   effects:
%
%   'Sigma' causes X to be smoothed before peak detection using a 2D
%   Gaussian kernel whose "sigma" parameter is given by the value of this
%   argument.
%
%       Note: Smoothing may be useful to locate peaks in noisy 
%       arrays. However, it may also cause the performance to deteriorate
%       if X contains sharp peaks. It is most likely to be useful if
%       neighbourhood suppression (see below) is not used.
%
%       The smoothing operations uses reflecting boundary conditions to
%       compute values close to the boundaries.
%
%   'Threshold' sets the minimum peak height. The value of X (after any
%   smoothing) at the peak position must be not less than the value of this
%   for the peak to be included in the output.
%
%   'Npeaks' sets the maximum number of peaks to be found. Up to NPEAKS
%   peaks are returned. If this option is used, the peaks are sorted in
%   descending order of height.
%
%   'Nhood', if set, causes the algorithm to change. Regional maxima are
%   not found; instead, successive maxima are found with neighbourhood
%   suppression. The value of this argument must be an odd integer, which
%   sets a minimum spatial separation between peaks.
%
%       When a peak has been found, no other peak with a position within an
%       NHOOD x NHOOD box centred on the first peak will be detected. Peaks
%       are found sequentially; for example, after the highest peak has
%       been found, the second will be found at the largest value in X
%       excepting the exclusion box found the first peak. This is similar
%       to the mechanism provided by the Toolbox function HOUGHPEAKS.
%
%   See also GSMOOTH2

% check arguments
params = checkargs(h, varargin{:});

% smooth the array
if params.sigma > 0
    h = gsmooth2(h, params.sigma, 'same');
end

if isempty(params.nhood)
    % First approach to peak finding: regional maxima
    
    % find the maxima
    maxarr = imregionalmax(h);
    
    % get array indices
    [r, c] = find(maxarr);
    v = h(sub2ind(size(h), r, c));
    
    % delete peaks below threshold
    if ~isempty(params.threshold)
        ind = v >= params.threshold;
        r = r(ind);
        c = c(ind);
        v = v(ind);
    end
    
    % reduce to N strongest peaks
    if ~isempty(params.npeaks)
        [~, ind] = sort(v, 'descend');
        ind = ind(1:min(length(ind), params.npeaks));
        r = r(ind);
        c = c(ind);
        v = v(ind);
    end
    
else
    % Second approach: iterative global max with suppression
    nhood2 = ([params.nhood params.nhood]-1) / 2;
    
    npks = params.npeaks;
    initsize = npks;
    if isempty(npks)
        initsize = length(h);
    end
    c = zeros(initsize, 1);
    r = zeros(initsize, 1);
    v = zeros(initsize, 1);
    
    np = 0;
    mn = min(h(:));
    thresh = params.threshold;
    if isempty(thresh)
        thresh = mn;
    end
    
    while true
        [v1, r1, c1] = max2(h);
        % stop if peak height below threshold, or have reached bottom
        if v1 < thresh || v1 == mn
            break;
        end
        np = np + 1;
        c(np) = c1;
        r(np) = r1;
        v(np) = v1;
        % stop if done enough peaks
        if np == npks
            break;
        end
        % suppress this peak
        rs = max([1 1], [r1 c1]-nhood2);
        re = min(size(h), [r1 c1]+nhood2);
        h(rs(1):re(1), rs(2):re(2)) = mn;
    end
    r(np+1:end) = [];   % trim
    c(np+1:end) = [];   % trim
    v(np+1:end) = [];   % trim
end

end

function params = checkargs(h, varargin)
% Argument checking
ip = inputParser;

% required
htest = @(h) validateattributes(h, {'double'}, {'real' 'nonsparse'});
ip.addRequired('h', htest);

% parameter/value pairs
stest = @(s) validateattributes(s, {'double'}, {'real' 'nonnegative' 'scalar'});
ip.addParamValue('sigma', 0, stest);
ip.addParamValue('threshold', [], stest);
nptest = @(n) validateattributes(n, {'double'}, {'real' 'positive' 'integer' 'scalar'});
ip.addParamValue('npeaks', [], nptest);
nhtest = @(n) validateattributes(n, {'double'}, {'odd' 'positive' 'scalar'});
ip.addParamValue('nhood', [], nhtest);
ip.parse(h, varargin{:});
params = ip.Results;
end


