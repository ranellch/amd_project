function img_new = FA_illum_norm_with_2masks(img_cur, featuremask, countmask, boxsize)
% img_new = FA_illum_norm_using_bkg(img_cur, featuremask, countmask, boxsize)

[qt_sparse, dims] = qtdecompMinCountThresh(countmask, boxsize^2, 1, img_cur);

x=[];
y=[];
o=[];
m=[];
for dim = dims
    bkgblks = qtgetblk(featuremask, qt_sparse, dim);
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

[X, Y] = meshgrid(1:size(featuremask,2), 1:size(featuremask,1));
Fo = scatteredInterpolant(x,y,o, 'natural');
omap = Fo(X,Y);
Fm = scatteredInterpolant(x,y,m, 'natural');
mmap = Fm(X,Y);

img_new = (img_cur - mmap) ./ omap;
img_new = im2unitRange( wiener2(img_new, [3 3]) );

figure
imshow(img_new);

end % end of function

