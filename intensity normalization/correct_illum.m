function [ Iout,background ] = correct_illum( I, thresh )
%UNTITLED Polynomial fitting motherfucker
addpath('../PolyfitnTools/')
addpath('../intensity normalization/DME Quadtree/')

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


%Sample background using quadtree decomposition
boxsize = Iheight/32;
[qt_sparse, dims] = qtdecompMinCountThresh(background, boxsize^2, 0, []);

x=[];
y=[];
o=[];
m=[];
indepvar = [];
depvarL = [];
depvarC = [];

for dim = dims
    bkgblks = qtgetblk(background, qt_sparse, dim);
    [imgblks, r, c] = qtgetblk(I, qt_sparse, dim);
    for i = 1:size(imgblks,3)
        tmpbkg = bkgblks(:,:,i);
        tmpimg = imgblks(:,:,i);
        data = tmpimg(tmpbkg);

        %check for boundaries, simulate mirror padding
        x = [x; c(i)+dim/2];
        y = [y; r(i)+dim/2];
        o = [o; std(data)];
        m = [m; mean(data)];
        if r(i)==1
            x = [x; c(i)+dim/2];
            y = [y; r(i)-dim/2];
            o = [o; std(data)];
            m = [m; mean(data)];
        end
        if c(i)==1
            x = [x; c(i)-dim/2];
            y = [y; r(i)+dim/2];
            o = [o; std(data)];
            m = [m; mean(data)];
        end
        if r(i)+dim>Iheight
            x = [x; c(i)+dim/2];
            y = [y; r(i)+dim*3/2];
            o = [o; std(data)];
            m = [m; mean(data)];
        end
        if c(i)+dim>Iwidth
            x = [x; c(i)+dim*3/2];
            y = [y; r(i)+dim/2];
            o = [o; std(data)];
            m = [m; mean(data)];
        end
        indepvar = [indepvar; x y];
        depvarL = [depvarL; m];
        depvarC = [depvarC; o];
    end
end

%Throw background pixels into polynomial fitter for illumination and
%contrast drifts
polymodelL = polyfitn(indepvar,depvarL,3);
polymodelC = polyfitn(indepvar,depvarC,3);

%get coordinates of entire image
y=[];
x=[];
for i = 1:Iwidth
    for j = 1:Iheight
        y = [y; j];
        x = [x; i];
    end
end
%Create surfaces spanning entire image
estimatesL = polyvaln(polymodelL,[x,y]);
estiamtesC = polyvaln(polymodelC,[x,y]);


L = zeros(size(I));
C = zeros(size(I));
L(:) = estimatesL;
C(:) = estiamtesC;

%Subtract background (i.e. camera function), divide by contrast drift
Iout = (I - L)./C;

%Normalize output to original histogram using least squares fitting
Iout = mat2gray(Iout,[mean(Iout(:))-3*std(Iout(:)), mean(Iout(:))+3*std(Iout(:))]);

end

