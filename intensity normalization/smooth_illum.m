function [ Iout,background ] = smooth_illum(I, varargin )
%SMOOTH_ILLUM removes illumination and contrast drifts from principal component image
%   IOUT = SMOOTH_ILLUM(I, k1, k2)
%   This function uses Mahalanobis distances to classify the most likely
%   background pixels.  It then uses bicubic interpolation with non-uniform sampling to estimate
%   illumination and contrast drifts.  Drifts are used to smooth orginal
%   image I using the formula U = (I - k1*L)/(k2*C).  If no values are
%   specified for k1 and k2 values default to 1

%Check input args
if nargin == 1
    k1 = 1;
    k2 = 1;
elseif nargin == 3 
    k1 = varargin{1};
    k2 = varargin{2};
else
    error('Incorrect number of input arguments')
end

I=double(I)./255;
Iwidth = size(I, 2);
Iheight = size(I, 1);
mu = zeros(size(I));
sigma = zeros(size(I));

%Mirror pad image by 1/6 and tesselate with gridboxes 1/3 height and width of image
%Get mean and standard deviation at the center of each gridbox (4 x 4 grid)
boxh = Iheight/3;
boxw = Iwidth/3;
paddedI = padarray(I,[boxh/2 boxw/2], 'symmetric', 'both');
for i = 1:4
    for j = 1:4
        cx = 1+(j-1)*boxw;
        cy = 1+(i-1)*boxh;
        window = paddedI(1+(i-1)*boxh:i*boxh, 1+(j-1)*boxw:j*boxw);
        mu(cy,cx) = mean2(window);
        sigma(cy,cx) = std(window(:));
    end
end

%Interpolate to get mean and standard deviation of every pixel
[y, x, mu1] = find(mu);
[xq, yq] = meshgrid(1:Iwidth, 1:Iheight);
mu = griddata(x, y, mu1, xq, yq,'cubic');

% figure
% mesh(xq,yq,mu);
% hold on
% plot3(x,y,mu1,'o');

[y, x, sigma] = find(sigma);
sigma = griddata(x, y, sigma, xq, yq,'cubic');


%Get background by thresholding Mahalanobis distance of every pixel
background = abs((I-mu)./sigma)<=1;
background = logical(background);
%   figure, imshow(background)

%Sample background 
Icenterx = round(Iwidth/2);
Icentery = round(Iheight/2);
rcoeffs = [.05 .2 .5 .75 .95];
r = Iwidth/2;

halfwinsz = floor((Iwidth/20)/2); %size of square sampling windows/2

L = zeros(size(I));
C = zeros(size(I));

for i = 1:5
  % create sampling rings
  [xgrid, ygrid] = meshgrid(1:Iwidth, 1:Iheight);
  x = xgrid - Icenterx; %place origin at center of image
  y = ygrid - Icentery;
  ring = x.^2 + y.^2 <= (rcoeffs(i)*r)^2;
  ring = bwperim(ring,8); 
  ring = logical(ring);
  angles = zeros(size(I));
  angles(ring) = atan2(y(ring),x(ring));
  numsampls = 4*2^(i-1);
  [rows, cols, thetas] = find(angles);
  allpoints = [rows, cols, thetas];
  allpoints = sortrows(allpoints, 3);
  spacing = length(thetas)/numsampls;
  for j = 1:numsampls 
      index = 1+round(spacing*(j-1));
      point = allpoints(index, 1:2);
      r = point(1);
      c = point(2);
      bounds = [r-halfwinsz,r+halfwinsz, c-halfwinsz,c+halfwinsz];
      if bounds(1) < 1 || bounds(2)<1 
          bounds(1) = 1; bounds(2) = 1+halfwinsz;
          point(1) = 1;
      elseif bounds(1) >Iheight || bounds(2)>Iheight
          bounds(2) = Iheight; bounds(1) = Iheight - halfwinsz;
          point(1) = Iheight;
      end
      if bounds(3) < 1 || bounds(4) < 1
          bounds(3) = 1; bounds(4) = 1+halfwinsz;
          point(2) = 1;
      elseif bounds(3) > Iwidth || bounds(4)>Iwidth
          bounds(4) = Iwidth; bounds(3) = Iwidth - halfwinsz;
          point(2) = Iwidth;
      end          
      window = I(bounds(1):bounds(2),bounds(3):bounds(4));
      mask = background(bounds(1):bounds(2), bounds(3):bounds(4));
      data = window(mask);
      L(point(1), point(2)) = mean2(data);
      C(point(1), point(2)) = std(data(:));
  end
end


%Sample corners
window = I(1:halfwinsz,1:halfwinsz);
mask = background(1:halfwinsz,1:halfwinsz);
data = window(mask);
L(1,1) = mean2(data);
C(1,1) = std(data(:));


window = I(1:halfwinsz,Iwidth-halfwinsz:Iwidth);
mask = background(1:halfwinsz,Iwidth-halfwinsz:Iwidth);
data = window(mask);
L(1,Iwidth) = mean2(data);
C(1,Iwidth) = std(data(:));


window = I(Iheight-halfwinsz:Iheight, 1:halfwinsz);
mask = background(Iheight-halfwinsz:Iheight, 1:halfwinsz);
data = window(mask);
L(Iheight,1) = mean2(data);
C(Iheight,1) = std(data(:));


window = I(Iheight-halfwinsz:Iheight,Iwidth-halfwinsz:Iwidth);
mask = background(Iheight-halfwinsz:Iheight,Iwidth-halfwinsz:Iwidth);
data = window(mask);
L(Iheight,Iwidth) = mean2(data);
C(Iheight,Iwidth) = std(data(:));



%Interpolate
[y, x, L1] = find(L);
[xq, yq] = meshgrid(1:Iwidth, 1:Iheight);
L = griddata(x, y, L1, xq, yq,'cubic');

% figure
% mesh(xq,yq,mu);
% hold on
% plot3(x,y,L1,'o');

[y, x, C] = find(C);
C = griddata(x, y, C, xq, yq,'cubic');

%Smooth
Iout = ((double(I)-k1*L)./(k2*C));
%.*std(I(:))+mean2(I);

%Ignore NaNs
Idefined = Iout(~isnan(Iout));
Idefined_orig = I(~isnan(Iout));
background = logical(background.*~isnan(Iout));

%Normalize output to original histogram using least squares fitting
Y = [Idefined(:),ones(length(Idefined(:)),1)];
X = Idefined_orig(:);
b = Y\X;
Iout = Iout.*b(1)+b(2);
Iout(isnan(Iout)) = 0;
Iout = mat2gray(Iout, [0 1]);
% figure, imshow(Iout)

      
      
 
