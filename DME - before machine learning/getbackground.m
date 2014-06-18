function [ background ] = getbackground(I,thresh)
%SMOOTH_ILLUM removes illumination and contrast drifts from principal component image
%   IOUT = SMOOTH_ILLUM(I, k1, k2)
%   This function uses Mahalanobis distances to classify the most likely
%   background pixels.  It then uses bicubic interpolation with non-uniform sampling to estimate
%   illumination and contrast drifts.  Drifts are used to smooth orginal
%   image I using the formula U = (I - k1*L)/(k2*C).  If no values are
%   specified for k1 and k2 values default to 1


I=double(I)./255;
Iwidth = size(I, 2);
Iheight = size(I, 1);
mu = zeros(size(I));
sigma = zeros(size(I));

%Mirror pad image by 1/6 and tesselate with gridboxes 1/3 height and width of image
%Get mean and standard deviation at the center of each gridbox (4 x 4 grid)
boxh = round(Iheight/8);
boxw = round(Iwidth/8);
paddedI = padarray(I,[boxh boxw], 'symmetric', 'both');
for i = 1:4
    for j = 1:4
        dims = [1+(i-1)*2*boxh, i*2*boxh, 1+(j-1)*2*boxw, j*2*boxw];
        window = paddedI(dims(1):dims(2),dims(3):dims(4));
        if i == 4
            dims(1) = Iheight;
        end
        if j == 4
            dims(3) = Iwidth;          
        end
        if nnz(window)/numel(window) > .5 %if greater than 50% of the window is nonzero
            mu(dims(1),dims(3)) = mean2(window);
            sigma(dims(1),dims(3)) = std(window(:));
        end
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
%   figure, imshow(background)

end
      
      
 
