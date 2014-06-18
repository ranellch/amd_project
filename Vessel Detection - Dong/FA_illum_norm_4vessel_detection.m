function [img_norm, nonvasmask, brightmask] = FA_illum_norm_4vessel_detection(img_cur, vesselmask, disp_flag)
%[img_norm, nonvasmask, brightmask] = FA_illum_norm_4vessel_detection(img_cur, vesselmask, disp_flag)

if ~exist('disp_flag', 'var')
    disp_flag = false;
end

brightmask = img_cur>=(mean(img_cur(vesselmask)));
brightmask = bwmorph(brightmask, 'fill');
brightmask = CCFilterRemoveSmallBlobs(brightmask, 16);
featuremask = vesselmask | brightmask;

img_norm = FA_illum_norm_with_bkg(img_cur, featuremask, 40, disp_flag);

lowT = prctile(img_norm(:), 10);
nonvasmask = img_norm<=lowT;
nonvasmask = bwmorph(nonvasmask, 'fill');
nonvasmask = CCFilterRemoveSmallBlobs(nonvasmask, 16);
if disp_flag
    imshow_sidebyside_origin_vs_filled(img_cur, nonvasmask);
end

vesselmask = vesselmask | vesselDetect(img_norm, 'matching');
brightmask1 = img_norm>=(mean(img_norm(vesselmask)));
brightmask1 = bwmorph(brightmask1, 'fill');
brightmask1 = CCFilterRemoveSmallBlobs(brightmask1, 16);
brightmask = brightmask | brightmask1;

featuremask = vesselmask | nonvasmask | brightmask;
img_norm = FA_illum_norm_with_bkg(img_cur, featuremask, 40, disp_flag);

end

