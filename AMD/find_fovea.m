function [ y,x ] = find_fovea( vessel_img, od_img )

stats = regionprops(od_img,'Centroid');
od_center = stats.Centroid;


end

