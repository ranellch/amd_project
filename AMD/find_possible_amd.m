function regions = find_possible_amd(avg_img,not_amd,x_fov,y_fov,debug)
%Generates large regions of interest based on areas without normal retina
%pixels, distance from fovea, and the presence of symmetry/normal hypo
%center

if debug >=1
    disp('[MAC+ROI(s)] Finding extent of macula and areas of possible AMD');
end
%Cluster potential amd areas
clusters = cluster_abnormal_regions(~not_amd);
figure, imagesc(clusters)

%Get clusters within 100 pixels of fovea, turn into solid regions
regions = zeros(size(clusters));
count = 1;
for k = 1:max(clusters(:))
    cluster = clusters == k;
    [y,x] = find(cluster);
    dists = sqrt((y-y_fov).^2+(x-x_fov).^2);
    if min(dists(:)) <= 100
        %get perimeter of cluster
        stats = regionprops(double(cluster),'Centroid');
        center = stats.Centroid;
        coords = get_radial_coords(size(cluster),center(1), center(2));
        radii = coords(:,:,1);
        perimeter = [];
        theta1 = -pi;
        step = pi/32;
        for theta = -pi+step:step:pi
            indices  = find((coords(:,:,2)>=theta1)&(coords(:,:,2)<=theta)&cluster);
            max_index = 0;
            max_radius = 0;
            for i = 1:length(indices)
                if radii(indices(i)) > max_radius
                    max_radius = radii(indices(i));
                    max_index = indices(i);
                end
            end
            if max_index == 0
                continue
            else
                perimeter = [perimeter; max_index];
            end
            theta1 = theta;
        end
        [r, c] = ind2sub(size(regions), perimeter);
        BW = roipoly(regions,c,r);
        regions(BW) = count;
        count = count + 1;
    end
end


end

