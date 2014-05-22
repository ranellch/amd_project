function [img] = imshow_sidebyside_origin_vs_filled(img_cur, fillmask)
%[img] = IMSHOW_SIDEBYSIDE_ORIGIN_VS_FILLED(img_cur, fillmask)
%   此处显示详细说明

img = imoverlay(img_cur, fillmask, [1 0 0]);
figure
subplot(1,2,1); imshow(img_cur);
subplot(1,2,2); imshow(img);
maximize

end

