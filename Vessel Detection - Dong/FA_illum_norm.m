function [img_norm, manualmask, vesselmask, nonvasmask, brightmask] = FA_illum_norm(img_cur, manualmask, disp_flag)
%[img_norm, manualmask, vesselmask, nonvasmask, brightmask] = FA_illum_norm(img_cur, manualmask, disp_flag)
%   temporarily: manual drawing of fovel macular zone

if ~exist('disp_flag', 'var')
    disp_flag = false;
end

if ~exist('manualmask', 'var') || isempty(manualmask)
    figure; imshow(img_cur); maximize;
    h = imfreehand(gca);
    outline = wait(h);
    manualmask = poly2mask(outline(:,1), outline(:,2), size(img_cur,1), size(img_cur,2));
end

vesselmask = vesselDetect(img_cur, 'matching');
brightmask = img_cur>=(mean(img_cur(vesselmask)));
brightmask = bwmorph(brightmask, 'fill');
brightmask = CCFilterRemoveSmallBlobs(brightmask, 2);
featuremask = vesselmask | manualmask | brightmask;

img_norm = FA_illum_norm_with_bkg(img_cur, featuremask, 40, disp_flag);

lowT = prctile(img_norm(:), 10);
nonvasmask = img_norm<lowT;
nonvasmask = bwmorph(nonvasmask, 'fill');
nonvasmask = CCFilterRemoveSmallBlobs(nonvasmask, 2);
if disp_flag
    imshow_sidebyside_origin_vs_filled(img_cur, nonvasmask);
end

vesselmask = vesselmask | vesselDetect(img_norm, 'matching');
brightmask1 = img_norm>=(mean(img_norm(vesselmask)));
brightmask1 = bwmorph(brightmask1, 'fill');
brightmask1 = CCFilterRemoveSmallBlobs(brightmask1, 2);
brightmask = brightmask | brightmask1;

featuremask = vesselmask | nonvasmask | manualmask | brightmask;
img_norm = FA_illum_norm_with_bkg(img_cur, featuremask, 40, disp_flag);

end

