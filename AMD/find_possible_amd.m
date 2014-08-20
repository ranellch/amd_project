function regions = find_possible_amd(avg_img,not_amd,x_fov,y_fov,debug)
%Generates large regions of interest based on areas without normal retina
%pixels, distance from fovea, and the presence of symmetry/normal hypo
%center

if debug >=1
    disp('[MAC+ROI(s)] Finding extent of macula and areas of possible AMD');
end
%Cluster potential amd areas
figure, imshow(not_amd)
clusters = cluster_abnormal_regions(~not_amd);
figure, imagesc(clusters)

%Get clusters within 200 pixels of fovea, turn into solid regions
regions = zeros(size(clusters));
count = 1;
se = strel('disk',10);
for k = 1:max(clusters(:))
    cluster = clusters == k;
    [y,x] = find(cluster);
    dists = sqrt((y-y_fov).^2+(x-x_fov).^2);
    if min(dists(:)) <= 200
        cluster = imclose(cluster,se);
        regions(cluster) = count;
        count = count+1;
    end
end
figure, imagesc(regions);


end

