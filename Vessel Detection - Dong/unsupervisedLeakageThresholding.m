function [DME_mask, enhancedImg] = unsupervisedLeakageThresholding(img_late, movingReg)
%UNSUPERVISEDLEAKAGETHRESHOLDING Summary of this function goes here
%   Detailed explanation goes here

enhancedImg = img_late - movingReg;
enhancedImg(enhancedImg<0) = 0;
% enhancedImg = im2unitRange(enhancedImg);

% enhancedImg = img_late./(movingReg+eps);

% Otsu thresholding
multiT = multithresh(enhancedImg);
DME_mask = enhancedImg>multiT(end);

% % clustering
% Y = quantile(enhancedImg(:), .95);
% label_init = ones(1,numel(enhancedImg));
% label_init(enhancedImg(:)>Y) = 2;
% label = litekmeans(enhancedImg(:)', 2, label_init);
% DME_mask = false(size(enhancedImg));
% DME_mask(label==2)=true;

% % show the raw results
% figure
% imshow(enhancedImg);
% maximize
% hold on
% contour(DME_mask);
% hold off

end

