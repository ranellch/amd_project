function rois = find_possible_amd(avg_img,not_amd,x_fov,y_fov)
%Generates large regions of interest based on areas without normal retina
%pixels, distance from fovea, and the presence of symmetry/normal hypo
%center


%Cluster potential amd areas
[final_clusters] = cluster_abnormal_regions(~not_amd);

%Calculate

%laplacian smoothing?

end

