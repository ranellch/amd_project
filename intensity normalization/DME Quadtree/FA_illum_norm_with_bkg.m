function img_new = FA_illum_norm_with_bkg(img_cur, featuremask, boxsize, disp_flag)
% img_new = FA_illum_norm_using_bkg(img_cur, featuremask, boxsize, disp_flag)

bkgmask = ~featuremask;
overlayimg = imoverlay(img_cur, featuremask, [1 0 0]);
[qt_sparse, dims] = qtdecompMinCountThresh(bkgmask, boxsize^2, disp_flag, overlayimg);

x=[];
y=[];
o=[];
m=[];
for dim = dims
    bkgblks = qtgetblk(bkgmask, qt_sparse, dim);
    [imgblks, r, c] = qtgetblk(img_cur, qt_sparse, dim);
    
    for i = 1:size(imgblks,3)
        tmpvbkgblk = bkgblks(:,:,i);
        tmpimgblk = imgblks(:,:,i);
        vespixels = tmpimgblk(tmpvbkgblk);
        x = [x; c(i)+dim/2];
        y = [y; r(i)+dim/2];
        o = [o; std(vespixels)];
        m = [m; mean(vespixels)];
        if r(i)==1
            x = [x; c(i)+dim/2];
            y = [y; r(i)-dim/2];
            o = [o; std(vespixels)];
            m = [m; mean(vespixels)];
        end
        if c(i)==1
            x = [x; c(i)-dim/2];
            y = [y; r(i)+dim/2];
            o = [o; std(vespixels)];
            m = [m; mean(vespixels)];
        end
        if r(i)+dim>size(img_cur,1)
            x = [x; c(i)+dim/2];
            y = [y; r(i)+dim*3/2];
            o = [o; std(vespixels)];
            m = [m; mean(vespixels)];
        end
        if c(i)+dim>size(img_cur,2)
            x = [x; c(i)+dim*3/2];
            y = [y; r(i)+dim/2];
            o = [o; std(vespixels)];
            m = [m; mean(vespixels)];
        end
    end
end

[X, Y] = meshgrid(1:size(bkgmask,2), 1:size(bkgmask,1));
Fo = scatteredInterpolant(x,y,o, 'natural');
omap = Fo(X,Y);
Fm = scatteredInterpolant(x,y,m, 'natural');
mmap = Fm(X,Y);

img_new = (img_cur - mmap) ./ omap;
img_new = wiener2(img_new, [3 3]);
img_new = im2unitRange(img_new);

if disp_flag
    figure
    imshow(img_new);
end

end % end of function

