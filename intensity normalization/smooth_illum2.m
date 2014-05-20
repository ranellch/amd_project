function [ Iout,background ] = smooth_illum2(I, varargin )
%SMOOTH_ILLUM removes illumination and contrast drifts from principal component image
%   IOUT = SMOOTH_ILLUM(I, k1, k2)
%   This function uses Mahalanobis distances to classify the most likely
%   background pixels.  It then uses bicubic interpolation with non-uniform sampling to estimate
%   illumination and contrast drifts.  Drifts are used to smooth orginal
%   image I using the formula U = (I - k1*L)/(k2*C).  If no values are
%   specified for k1 and k2 values default to 1

if size(I,3) ~= 1
    I=rgb2gray(I);
end

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
background = abs((I-mu)./sigma)<=.7;
background = logical(background);

%Sample background 
boxh = Iheight/8;
boxw = Iwidth/8; %size of square sampling windows
paddedback = padarray(background,[boxh/2 boxw/2], 'symmetric', 'both');
paddedI = padarray(I,[boxh/2 boxw/2], 'symmetric', 'both');

L = zeros(size(I));
C = zeros(size(I));

for i = 1:9
    for j = 1:9
        cx = 1+(j-1)*boxw;
        cy = 1+(i-1)*boxh;
        window = paddedI(1+(i-1)*boxh:i*boxh, 1+(j-1)*boxw:j*boxw);
        mask = paddedback(1+(i-1)*boxh:i*boxh, 1+(j-1)*boxw:j*boxw);
        data = window(mask);
        L(cy,cx) = mean2(data);
        C(cy,cx) = std(data(:));
    end
end

%Interpolate
[y, x, L1] = find(L);
[xq, yq] = meshgrid(1:Iwidth, 1:Iheight);
L = griddata(x, y, L1, xq, yq,'cubic');

figure
mesh(xq,yq,L);
hold on
plot3(x,y,L1,'o');

[y, x, C] = find(C);
C = griddata(x, y, C, xq, yq,'cubic');

%Smooth
Iout = (I-k1*L)./(k2*C);

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

H = fspecial('gaussian', [3 3], 1);
Iout = imfilter(Iout, H);

% figure, imshow(Iout)

      
      
 
