%LBP returns the local binary pattern image or LBP histogram of an image.
%  J = LBP_C(I,R,N,MAPPING,MODE) returns either a local binary pattern
%  coded image or the local binary pattern histogram of an intensity
%  image I. The LBP codes are computed using N sampling points on a 
%  circle of radius R and using mapping table defined by MAPPING. 
%  See the getmapping function for different mappings and use 0 for
%  no mapping. Possible values for MODE are
%       'h' or 'hist'  to get a histogram of LBP codes
%       'nh'           to get a normalized histogram
%       'i' specifies the return of an LBP image matrix
%
%  J = LBP_C(I) returns the original (basic) LBP histogram of image I
%  with 8 separate contrast bins in J
%
%  J = LBP_C(I,SP,MAPPING,MODE) computes the LBP codes using n sampling
%  points defined in (n * 2) matrix SP. The sampling points should be
%  defined around the origin (coordinates (0,0)).
%
%           MODE 
%
%  Examples
%  --------
%       I=imread('rice.png');
%       mapping=getmapping(8,'u2'); 
%       H1=LBP(I,1,8,mapping,'h'); %LBP histogram in (8,1) neighborhood
%                                  %using uniform patterns
%       subplot(2,1,1),stem(H1);
%
%       H2=LBP(I);
%       subplot(2,1,2),stem(H2);
%
%       SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
%       I2=LBP(I,SP,0,'i'); %LBP code image using sampling points in SP
%                           %and no mapping. Now H2 is equal to histogram
%                           %of I2.

function [result] = lbp_c(varargin) % image,radius,neighbors,mapping,mode)
% Version 0.3.2
% Authors: Marko Heikkilä and Timo Ahonen

% Changelog
% Version 0.3.2: A bug fix to enable using mappings together with a
% predefined spoints array
% Version 0.3.1: Changed MAPPING input to be a struct containing the mapping
% table and the number of bins to make the function run faster with high number
% of sampling points. Lauge Sorensen is acknowledged for spotting this problem.


% Check number of input arguments.
error(nargchk(1,5,nargin));

image=varargin{1};
d_image=double(image);

if nargin==1
    spoints=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    neighbors=8;
    mapping=0;
    mode='h';
end

if (nargin == 2) && (length(varargin{2}) == 1)
    error('Input arguments');
end

if (nargin > 2) && (length(varargin{2}) == 1)
    radius=varargin{2};
    neighbors=varargin{3};
    
    spoints=zeros(neighbors,2);

    % Angle step.
    a = 2*pi/neighbors;
    
    for i = 1:neighbors
        spoints(i,1) = -radius*sin((i-1)*a);
        spoints(i,2) = radius*cos((i-1)*a);
    end
    
    if(nargin >= 4)
        mapping=varargin{4};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end
    
    if(nargin >= 5)
        mode=varargin{5};
    else
        mode='h';
    end
end

if (nargin > 1) && (length(varargin{2}) > 1)
    spoints=varargin{2};
    neighbors=size(spoints,1);
    
    if(nargin >= 3)
        mapping=varargin{3};
        if(isstruct(mapping) && mapping.samples ~= neighbors)
            error('Incompatible mapping');
        end
    else
        mapping=0;
    end
    
    if(nargin >= 4)
        mode=varargin{4};
    else
        mode='h';
    end   
end

% Determine the dimensions of the input image.
[ysize, xsize] = size(image);



miny=min(spoints(:,1));
maxy=max(spoints(:,1));
minx=min(spoints(:,2));
maxx=max(spoints(:,2));

% Block size, each LBP code is computed within a block of size bsizey*bsizex
bsizey=ceil(max(maxy,0))-floor(min(miny,0))+1;
bsizex=ceil(max(maxx,0))-floor(min(minx,0))+1;

% Coordinates of origin (0,0) in the block
origy=1-floor(min(miny,0));
origx=1-floor(min(minx,0));

% Minimum allowed size for the input image depends
% on the radius of the used LBP operator.
if(xsize < bsizex || ysize < bsizey)
  error('Too small input image. Should be at least (2*radius+1) x (2*radius+1)');
end

% Calculate dx and dy;
dx = xsize - bsizex;
dy = ysize - bsizey;

% Fill the center pixel matrix C.
C = image(origy:origy+dy,origx:origx+dx);
d_C = double(C);

bins = 2^neighbors;

% Initialize the result and contrast matrices with zeros.
result=zeros(dy+1,dx+1);
sumdiffhi = result;
n_diffhi = result;
sumdifflo = result;
n_difflo = result;

%Compute the LBP code image

for i = 1:neighbors
  y = spoints(i,1)+origy;
  x = spoints(i,2)+origx;
  % Calculate floors, ceils and rounds for the x and y.
  fy = floor(y); cy = ceil(y); ry = round(y);
  fx = floor(x); cx = ceil(x); rx = round(x);
  % Check if interpolation is needed.
  if (abs(x - rx) < 1e-6) && (abs(y - ry) < 1e-6)
    % Interpolation is not needed, use original datatypes
    N = image(ry:ry+dy,rx:rx+dx);
    N = double(N);
    D = N >= C;
    L = ~D; %keep track of which values are less than threshold
  else
    % Interpolation needed, use double type images 
    ty = y - fy;
    tx = x - fx;

    % Calculate the interpolation weights.
    w1 = (1 - tx) * (1 - ty);
    w2 =      tx  * (1 - ty);
    w3 = (1 - tx) *      ty ;
    w4 =      tx  *      ty ;
    % Compute interpolated pixel values
    N = w1*d_image(fy:fy+dy,fx:fx+dx) + w2*d_image(fy:fy+dy,cx:cx+dx) + ...
        w3*d_image(cy:cy+dy,fx:fx+dx) + w4*d_image(cy:cy+dy,cx:cx+dx);
    N = double(N);
    D = N >= d_C; 
    L = ~D; %keep track of which values are less than threshold
  end  
  % Update the result matrix.
  v = 2^(i-1);
  result = result + v*D;
  sumdiffhi = sumdiffhi + N.*D; % add up values greater than thresh 
  n_diffhi = n_diffhi + D; %get number of 1s
  sumdifflo = sumdifflo + N.*L; % add up valeus less than thresh
  n_difflo = n_difflo + L; %get number of 0s
end

n_diffhi(n_diffhi==0)=1;
n_difflo(n_difflo==0)=1;
contrast = sumdiffhi./n_diffhi - sumdifflo./n_difflo; %calculate contrast matrix



%Apply mapping if it is defined
if isstruct(mapping)
    bins = mapping.num;
    for i = 1:size(result,1)
        for j = 1:size(result,2)
            result(i,j) = mapping.table(result(i,j)+1);
        end
    end
end

%separate results matrix by contrast ranges
%contrast bin cutoffs: 3.8571    5.8000    7.4286   9.1667   11.3333   14.8000   24.4667
hist_layers = logical(zeros([size(result), 4]));
edges = [3.8571    9.1667    24.4667];
hist_out = zeros(bins,4);

for i = 1:4;
    if i == 1
        ubound = edges(i); 
        hist_layers(:,:,i) = contrast <= ubound;
    elseif i == 4
        lbound = edges(i-1);
        hist_layers(:,:,i) = contrast > lbound;
    else
        ubound = edges(i); lbound = edges(i-1);
        hist_layers(:,:,i) = contrast > lbound & contrast <= ubound;
    end
end

if (strcmp(mode,'h') || strcmp(mode,'hist') || strcmp(mode,'nh'))
    % Return with LBP histogram if mode equals 'hist'.
        
for i = 1:4;
        hist_out(:,i) = hist(result(hist_layers(:,:,i)),0:(bins-1))';
end
    result = hist_out;
    
    if (strcmp(mode,'nh'))
        result=result./repmat(sum(sum(result)),bins,4);
    end
else
    %Otherwise return a size(result) by 8 matrix of unsigned integer images
    Iout=zeros([size(result), 4]); 
    for i = 1:4;
        Iout(:,:,i) = result.*hist_layers(:,:,i);
    end
    if ((bins-1)<=intmax('uint8'))
        result=uint8(Iout);
    elseif ((bins-1)<=intmax('uint16'))
        result=uint16(Iout);
    else
        result=uint32(Iout);
    end
end

end




