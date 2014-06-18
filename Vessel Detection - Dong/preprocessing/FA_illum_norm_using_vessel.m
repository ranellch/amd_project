function img_new = FA_illum_norm_using_vessel(img_cur, vesselmap, boxsize)
% img_new = FA_illum_norm_using_vessel(img_cur, vesselmap, boxsize)

img = imoverlay(img_cur, vesselmap, [1 0 0]);
[qt_sparse, dims] = qtdecompMinCountThresh(vesselmap, boxsize^2, 1, img);

o=[];
m=[];
for dim = dims
    vesselblks = qtgetblk(vesselmap, qt_sparse, dim);
    imgblks = qtgetblk(img_cur, qt_sparse, dim);
    
    for i = 1:size(imgblks,3)
        tmpvbkgblk = vesselblks(:,:,i);
        tmpimgblk = imgblks(:,:,i);
        vespixels = tmpimgblk(tmpvbkgblk);
        o = [o; std(vespixels)];
        m = [m; mean(vespixels)];
    end
end

md = abs(m - mean(m));
[~, id] = min(md);
m0 = m(id);
o0 = o(id);

x=[];
y=[];
o=[];
m=[];
for dim = dims
    bkgblks = qtgetblk(vesselmap, qt_sparse, dim);
    [imgblks, r, c] = qtgetblk(img_cur, qt_sparse, dim);
    
    for i = 1:size(imgblks,3)
        tmpvbkgblk = bkgblks(:,:,i);
        tmpimgblk = imgblks(:,:,i);
        vespixels = tmpimgblk(tmpvbkgblk);
        x = [x; c(i)+dim/2];
        y = [y; r(i)+dim/2];
        o = [o; std(vespixels)/o0];
        m = [m; mean(vespixels)-m0];
        if r(i)==1
            x = [x; c(i)+dim/2];
            y = [y; r(i)-dim/2];
            o = [o; std(vespixels)/o0];
            m = [m; mean(vespixels)-m0];
        end
        if c(i)==1
            x = [x; c(i)-dim/2];
            y = [y; r(i)+dim/2];
            o = [o; std(vespixels)/o0];
            m = [m; mean(vespixels)-m0];
        end
        if r(i)+dim>size(img_cur,1)
            x = [x; c(i)+dim/2];
            y = [y; r(i)+dim*3/2];
            o = [o; std(vespixels)/o0];
            m = [m; mean(vespixels)-m0];
        end
        if c(i)+dim>size(img_cur,2)
            x = [x; c(i)+dim*3/2];
            y = [y; r(i)+dim/2];
            o = [o; std(vespixels)/o0];
            m = [m; mean(vespixels)-m0];
        end
    end
end

[X, Y] = meshgrid(1:size(vesselmap,2), 1:size(vesselmap,1));
Fo = scatteredInterpolant(x,y,o, 'natural', 'nearest');
omap = Fo(X,Y);
Fm = scatteredInterpolant(x,y,m, 'natural', 'nearest');
mmap = Fm(X,Y);

img_new = (img_cur - mmap) ./ omap;
img_new = im2unitRange( wiener2(img_new, [3 3]) );

figure
imshow(img_new);

end % end of function

