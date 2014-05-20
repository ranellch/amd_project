function [ Idrift ] = villum_drift( I )
%VILLUM_DRIFT calculates illumination drift map using vessel sampling
%   IDRIFT = VILLIM_DRIFT(I) returns the grayscale intensity drift
%   pattern for later subtraction from the original image. 
%   This function samples vessel pixels to generate a bicubic interpolation
%   that approximates the illumination drift


vskel =  vessel_detection_old(I);
Isparse = double(I.*uint8(vskel))/255;
figure, imshow(Isparse)

%2D bicubic interpolation
imgheight = size(I,1);
imgwidth = size(I,2);
% Ia = zeros(imgheight,imgwidth);
% Ib = zeros(imgheight,imgwidth);
%Interpolate
[y, x, L1] = find(Isparse);
[xq, yq] = meshgrid(1:imgwidth, 1:imgheight);
Idrift = griddata(x, y, L1, xq, yq,'cubic');
% for i = 1:imgheight
%     [x,y,v] = find(Isparse(i,:));
%     if ~isempty(v)
%         Ia(i,:) = interp1(y,v,1:imgwidth,'cubic');
%     else
%         Ia(i,:) = zeros(1,imgwidth);
%     end
% end
% 
% for i = 1:imgwidth
%     [x,y,v] = find(Isparse(:,i));
%     if ~ismpty(I)
%         Ib(:,i) = interp1(x,v,1:imgheight,'cubic');
%     else
%         Ib(:,i) = zeros(imgheight,1);
%     end
% end

% Ib = rot90(rot90(fliplr(Ib)));

%  Approximation of the image background
% Idrift = (Ia+Ib)/2;


figure, imshow(Idrift)


end

