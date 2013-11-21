function [ Iout ] = smooth_illum(I, varargin )
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

%Pad image by 1/8 and tesselate with gridboxes 1/4 height and width of image
%Get mean and standard deviation at the center of each gridbox (5 x 5 grid)
boxh = Iheight/4;
boxw = Iwidth/4;
paddedI = padarray(I,[round(boxh/2) round(boxw/2)], 'symmetric', 'both');
for i = 1:5
    for j = 1:5
        dims = [1+round((i-1)*boxh), round(i*boxh), 1+round((j-1)*boxw), round(j*boxw)];
        window = paddedI(dims(1):dims(2),dims(3):dims(4));
        if i == 5
            dims(1) = Iheight;
        end
        if j == 5
            dims(3) = Iwidth;          
        end
        if nnz(window)/numel(window) > .1 %if greater than 10% of the window is nonzero
            mu(dims(1),dims(3)) = mean2(window);
            sigma(dims(1),dims(3)) = std(window(:));
        end
    end
end


%Interpolate to get mean and standard deviation of every pixel
[y, x, mu1] = find(mu);
[xq, yq] = meshgrid(1:Iwidth, 1:Iheight);
mu = griddata(x, y, mu1, xq, yq,'cubic');

figure
mesh(xq,yq,mu);
hold on
plot3(x,y,mu1,'o');


[y, x, sigma] = find(sigma);
sigma = griddata(x, y, sigma, xq, yq,'cubic');


%Get background by thresholding Mahalanobis distance of every pixel
background = abs((I-mu)./sigma)<=1;
background = logical(background);
%  figure, imshow(background)

%Sample background 
Icenterx = round(Iwidth/2);
Icentery = round(Iheight/2);
rcoeffs = [.05 .2 .5 .75 .9];
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
      dims = [r-halfwinsz,r+halfwinsz, c-halfwinsz,c+halfwinsz];
      if dims(1) < 1 || dims(2)<1 
          dims(1) = 1; dims(2) = 1+halfwinsz;
          point(1) = 1;
      elseif dims(1) >Iheight || dims(2)>Iheight
          dims(2) = Iheight; dims(1) = Iheight - halfwinsz;
          point(1) = Iheight;
      end
      if dims(3) < 1 || dims(4) < 1
          dims(3) = 1; dims(4) = 1+halfwinsz;
          point(2) = 1;
      elseif dims(3) > Iwidth || dims(4)>Iwidth
          dims(4) = Iwidth; dims(3) = Iwidth - halfwinsz;
          point(2) = Iwidth;
      end          
      window = I(dims(1):dims(2),dims(3):dims(4));
      mask = background(dims(1):dims(2), dims(3):dims(4));
      data = window(mask);
      if nnz(data)/numel(data) > .1
          L(point(1), point(2)) = mean2(data);
          C(point(1), point(2)) = std(data(:));
      end
  end
end


%Sample corners
window = I(1:halfwinsz,1:halfwinsz);
mask = background(1:halfwinsz,1:halfwinsz);
data = window(mask);
if nnz(data)/numel(data) > .1
    L(1,1) = mean2(data);
    C(1,1) = std(data(:));
end

window = I(1:halfwinsz,Iwidth-halfwinsz:Iwidth);
mask = background(1:halfwinsz,Iwidth-halfwinsz:Iwidth);
data = window(mask);
if nnz(data)/numel(data) > .1
    L(1,Iwidth) = mean2(data);
    C(1,Iwidth) = std(data(:));
end

window = I(Iheight-halfwinsz:Iheight, 1:halfwinsz);
mask = background(Iheight-halfwinsz:Iheight, 1:halfwinsz);
data = window(mask);
if nnz(data)/numel(data) > .1
    L(Iheight,1) = mean2(data);
    C(Iheight,1) = std(data(:));
end

window = I(Iheight-halfwinsz:Iheight,Iwidth-halfwinsz:Iwidth);
mask = background(Iheight-halfwinsz:Iheight,Iwidth-halfwinsz:Iwidth);
data = window(mask);
if nnz(data)/numel(data) > .1
    L(Iheight,Iwidth) = mean2(data);
    C(Iheight,Iwidth) = std(data(:));
end


%Interpolate
[y, x, L1] = find(L);
[xq, yq] = meshgrid(1:Iwidth, 1:Iheight);
L = griddata(x, y, L1, xq, yq,'cubic');

[y, x, C] = find(C);
C = griddata(x, y, C, xq, yq,'cubic');

%Smooth
Iout = ((double(I)-k1*L)./(k2*C)).*std(I(:))+mean2(I);

%Ignore NaNs
Idefined = Iout(~isnan(Iout));
Idefined_orig = I(~isnan(Iout));

%Normalize output to original histogram using least squares fitting
Y = [Idefined(:),ones(length(Idefined(:)),1)];
X = Idefined_orig(:);
b = Y\X;
Iout = Iout.*b(1)+b(2);
Iout(isnan(Iout)) = 0;
Iout = mat2gray(Iout, [0 1]);
% figure, imshow(Iout)

      
      
 
