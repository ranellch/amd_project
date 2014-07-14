function [ Iout,background ] = correct_illum( I, thresh )
%UNTITLED Polynomial fitting motherfucker
addpath('../../PolyfitnTools/')

if size(I,3) ~= 1
    I=rgb2gray(I);
end

if ~isa(I,'double')
    I=im2double(I);
end
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
background = abs((I-mu)./sigma)<=thresh;
background = logical(background);

%Throw background pixels into polynomial fitter
indepvar = [];
depvar = [];
for y = 1:8:Iheight
    for x = 1:8:Iwidth
        if background(y,x) == 1
            indepvar = [indepvar;x y];
            depvar = [depvar; I(y,x)];
        end
    end
end
polymodel = polyfitn(indepvar,depvar,3);

%get coordinates of entire image
y=[];
x=[];
for i = 1:Iwidth
    for j = 1:Iheight
        y = [y; j];
        x = [x; i];
    end
end
%Create surface spanning entire image
estimates = polyvaln(polymodel,[x,y]);
C = zeros(size(I));
 C(:) = estimates;
%    figure , imshow(mat2gray(C))     

%Divide out surface (i.e. "camera function)
Iout = I./C;

%Supress extreme outliers
 Iout(Iout>2) = 2;
 Iout(Iout<0) = 0;

H = fspecial('gaussian', [3 3], 1);
Iout = imfilter(Iout, H, 'symmetric');

end

