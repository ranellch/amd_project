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

Iwidth = size(I, 2);
Iheight = size(I, 1);
background = zeros(size(I));

%Get background using standard deviations of 3 by 3 bo
for i = 1:3
    for j = 1:3
        dims = [1+round((i-1)*Iheight/3), round(i*Iheight/3), 1+round((j-1)*Iwidth/3), round(j*Iwidth/3)];
        window = I(dims(1):dims(2),dims(3):dims(4));
        mu = mean2(window);
        sigma = std(double(window(:)));
        background(dims(1):dims(2),dims(3):dims(4)) = abs((double(window)-mu)./sigma)<=1;
           
    end
end
background = logical(background);
figure, imshow(background)
        
%Sample background
Icenterx = round(Iwidth/2);
Icentery = round(Iheight/2);
rcoeffs = [.05 .2 .5 .8 .9 1];
r = Iwidth/2;

halfwinsz = floor((Iwidth/20)/2); %size of square sampling windows/2

L = zeros(size(I));
C = zeros(size(I));

for i = 1:6
% create sampling rings
 [xgrid, ygrid] = meshgrid(1:Iwidth, 1:Iheight);   
  x = xgrid - Icenterx; %place origin at center of image
  y = ygrid - Icentery;
  ring = x.^2 + y.^2 <= (rcoeffs(i)*r)^2;
  ring = bwperim(ring,8); 
  ring = logical(ring);
  angles = zeros(size(I));
  angles(ring) = atan2(y(ring),x(ring));
  if i == 6
      numsampls = 10;
  else
      numsampls = 4^i;
  end
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
      L(point(1), point(2)) = mean2(data);
      C(point(1), point(2)) = std(double(data(:)));
  end
end


%Sample corners
window = I(1:halfwinsz,1:halfwinsz);
mask = background(1:halfwinsz,1:halfwinsz);
data = window(mask);
L(1,1) = mean2(data);
C(1,1) = std(double(data(:)));

window = I(1:halfwinsz,Iwidth-halfwinsz:Iwidth);
mask = background(1:halfwinsz,Iwidth-halfwinsz:Iwidth);
data = window(mask);
L(1,Iwidth) = mean2(data);
C(1,Iwidth) = std(double(data(:)));

window = I(Iheight-halfwinsz:Iheight, 1:halfwinsz);
mask = background(Iheight-halfwinsz:Iheight, 1:halfwinsz);
data = window(mask);
L(Iheight,1) = mean2(data);
C(Iheight,1) = std(double(data(:)));

window = I(Iheight-halfwinsz:Iheight,Iwidth-halfwinsz:Iwidth);
mask = background(Iheight-halfwinsz:Iheight,Iwidth-halfwinsz:Iwidth);
data = window(mask);
L(Iheight,Iwidth) = mean2(data);
C(Iheight,Iwidth) = std(double(data(:)));

figure, imshow(L)

%Interpolate
[y, x, L] = find(L);
y=flipud(y);
[xq, yq] = meshgrid(1:Iwidth, 1:Iheight);
L2 = griddata(x, y, L, xq, yq,'cubic');
figure
mesh(xq,yq,L2);
hold on
plot3(x,y,L,'o');

[y, x, C] = find(C);
y =flipud(y);
C2 = griddata(x, y, C, xq, yq,'cubic');
figure
mesh(xq,yq,C2);
hold on
plot3(x,y,C,'o');

%Smooth
mu_original = mean2(I)
sig_original = std(double(I(:)))
mean2(C2)
mean2(L2)
Iout = ((double(I)-k1*L2)./(k2*C2))+mu_original;
% Iout = im2uint8(mat2gray(Iout));
figure, imshow(Iout)
      
      
 
