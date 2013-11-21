function [ Idist ] = villum_dist( I )
%VILLUM_DRIFT calculates illumination drift map using vessel sampling
%   IDRIFT = VILLIM_DRIFT(I) returns the grayscale intensity drift
%   pattern for later subtraction from the original image. 
%   This function samples vessel pixels to generate a bicubic interpolation
%   that approximates the illumination drift


vskel =  vessel_detection(I);
Isparse = double(I.*uint8(vskel));
figure, imshow(Isparse)

%2D non-uniform bicubic interpolation
imgheight = size(I,1);
imgwidth = size(I,2);
[y, x, v] = find(Isparse);
[x,y]=meshgrid(x,y);
Ib = interp2(x, y, v, 1:imgwidth, 1:imgheight);

Idist=uint8(Ib);


figure, imshow(Idist)


end

