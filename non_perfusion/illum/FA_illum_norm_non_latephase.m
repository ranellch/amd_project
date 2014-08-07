function [img_norm, manualmask, nonvasmask, brightmask] = FA_illum_norm_non_latephase(img_cur, manualmask, vesselmask, disp_flag)
%[img_norm, manualmask, nonvasmask, brightmask] =
%FA_illum_norm(img_cur,manualmask,vesselmask,disp_flag)
%   temporarily: manual drawing of fovel macular zone

if ~exist('disp_flag', 'var')
    disp_flag = false;
end

if ~exist('manualmask', 'var') || isempty(manualmask)
    stop_flag = false;
    r = 118;
    figure('WindowButtonMotionFcn', @figMouseOver, ...
        'WindowScrollWheelFcn',@figScroll, ...
        'WindowButtonDownFcn', @figButtonDown);
    colormap(gray);
    imagesc(img_cur);
    axis image off
    
    while ~stop_flag
        pause(1);
    end
    
    manualmask = poly2mask(x, y, size(img_cur,1), size(img_cur,2));
end
    function figMouseOver(src, evnt)
        c = get(gca, 'CurrentPoint');
        [x, y] = calcPerimPoints(c(1,1), c(1,2), r);
        imagesc(img_cur); 
        axis image off
        hold on;
        plot(x, y, 'r-');hold off;
    end
    function figScroll(src, evnt)
        r = r - evnt.VerticalScrollCount * 3;
        if r<0
            r = 1;
        end
        c = get(gca, 'CurrentPoint');
        [x, y] = calcPerimPoints(c(1,1), c(1,2), r);
        imagesc(img_cur); 
        axis image off
        hold on;
        plot(x, y, 'r-');hold off;
    end
    function figButtonDown(src, evnt)
        set(src, 'WindowButtonMotionFcn', [], ...
        'WindowScrollWheelFcn',[], 'WindowButtonDownFcn', []);
        c = get(gca, 'CurrentPoint');
        [x, y] = calcPerimPoints(c(1,1), c(1,2), r);
        imagesc(img_cur); 
        axis image off
        hold on;
        plot(x, y, 'g-');hold off;
        stop_flag = true;
    end

brightmask = img_cur>=(mean(img_cur(vesselmask)));
brightmask = bwmorph(brightmask, 'fill');
brightmask = CCFilterRemoveSmallBlobs(brightmask, 2);
featuremask = vesselmask | manualmask | brightmask;

img_norm = FA_illum_norm_with_bkg(img_cur, featuremask, 50, disp_flag);

lowT = prctile(img_norm(:), 10);
nonvasmask = img_norm<lowT;
nonvasmask = bwmorph(nonvasmask, 'fill');
nonvasmask = CCFilterRemoveSmallBlobs(nonvasmask, 2);
if disp_flag
    imshow_sidebyside_origin_vs_filled(img_cur, nonvasmask);
end

brightmask1 = img_norm>=(mean(img_norm(vesselmask)));
brightmask1 = bwmorph(brightmask1, 'fill');
brightmask1 = CCFilterRemoveSmallBlobs(brightmask1, 2);
brightmask = brightmask | brightmask1;

featuremask = vesselmask | nonvasmask | brightmask;
img_norm = FA_illum_norm_with_bkg(img_cur, featuremask, 50, disp_flag);

end

function [x, y] = calcPerimPoints(cx, cy, r)
theta = linspace(0, 2*pi, 180);
x = cx + r * cos(theta);
y = cy + r * sin(theta);
end

