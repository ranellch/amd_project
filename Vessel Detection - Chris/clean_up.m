CC = bwconncomp(binary_img);
stats = regionprops(CC,'Extent','Eccentricity');
for i = 1:length(stats)
    if stats(i).Extent > 0.15 && stats(i).Eccentricity < 0.95
        binary_img(CC.PixelIdxList{i}) = 0;
    end
end