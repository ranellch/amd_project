function [ varargout ] = wavefilter( wname, type )
%WAVEFILTER Create dicrete wavelet decomposition and reconstruction filters 
%   [VARARGOUT] = WAVEFILTER(WNAME,TYPE) returns the decomposition and/or
%   reconstruction filters used in the computation of the forward and
%   inverse FWT (fast wavelet transform)
%
%   EXAMPLES:
%       [ld, hd, lr, hr] = wavefilter('haar')
%       Get the low and highpass decomposition (ld, hd) and 
%       reconstruction (lr, hr) filters for wavelet 'haar'.
%       
%       [ld,hd] = wavefilter('haar','d')
%       Get decomposition filters ld and hd.
%
%       [lr,hr] = wavefilter('haar','r')
%       Get reconstruction filters lr and hr.
%
%   INPUTS:
%       WNAME                Wavelet Name
%       ------------------------------------------------------------------
%       'haar' or 'db1'      Haar
%       'db4'                4th order Daubechies
%       
%       Not yet added:
%       'sym4'               4th order Symlets
%       'bior6.8'            Cohen-Daubechies-Feauveau biorthogonal
%       'jpeg9.7'            Antonini-Barlaud-Mathieu-Daubechies
%
%       TYPE                 Filter Type
%       ------------------------------------------------------------------
%       'd'                  Decomposition filters
%       'r'                  Reconstruction filters
%
%   Related functions: WAVEFAST, WAVEBACK

% Check args
narginchk(1,2);

if (nargin == 1 && nargout ~=4) || (nargin == 2 && nargout ~=2)
    error('Invalid number of output arguments');
end

if (nargin == 1) && ~ischar(wname)
    error('WNAME must be a string');
end

if (nargin == 2) && ~ischar(type)
    error('TYPE must be a string');
end

%Create filters for requested wavelet
switch lower(wname)
    case {'haar', 'db1'}
        ld = [1 1]/sqrt(2); hd = [-1 1]/sqrt(2);
        lr = ld;            hr = -hd;
        
    case 'db4'
        ld = [-1.059740178499728e-002 3.288301166698295e-002 ...
               3.084138183598697e-002 -1.870348117188811e-001 ...
               -2.798376941698385e-002 6.308807679295904e-001 ...
               7.148465705525415e-001 2.303778133088552e-001];
         t = (0:7);
         hd = ld;   hd(end:-1:1) = cos(pi*t).*ld;
         lr = ld;   lr(end:-1:1) = ld;
         hr = cos(pi*t).*ld;
    
    otherwise
    error('Unrecognizable wavelet name (WNAME)');
end

%Output the requested filters
if (nargin == 1)
    varargout(1:4) = {ld,hd,lr,hr};
else
    switch lower(type(1))
        case 'd'
            varargout = {ld,hd};
        case 'r'
            varargout = {lr, hr};
        otherwise
            error('Unrecognizable filter TYPE');
    end
end

end

