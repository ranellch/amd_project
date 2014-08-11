function [ feature_vectors ] = get_fv_hyper(lc,Al,hypo_centroid,corrected_img)
%Returns instance matrix of length numclusters(lc) in order of lc labeling

numclusters = max(lc(:));

feature_vectors = zeros(numclusters,7);
for k = 1:numclusters
    region = lc == k;
    feature_vectors(k,1) = mean(corrected_img(region));
    feature_vectors(k,2) = std(corrected_img(region));
    feature_vectors(k,3) = min(corrected_img(region));
    feature_vectors(k,4) = max(corrected_img(region));
    %find difference in intensities between current region and all adjacent
    %regions
    adjacents = Al{k};
    s = 0;
    n = 0;
    maxdiff = 0;
    for i = 1:length(adjacents)
        diff = feature_vectors(k,1) - mean(corrected_img(lc == adjacents(i)));
        if diff > maxdiff
            maxdiff = diff;
        end
        s = s+sum(corrected_img(lc == adjacents(i)));
        n = n+numel(corrected_img(lc == adjacents(i)));
    end
    feature_vectors(k,5) = maxdiff;
    feature_vectors(k,6) = feature_vectors(k,1) - s/n; %average difference
    %get distance from hypo/fovea
    region_center = regionprops(region,'Centroid');
    region_center = round(region_center.Centroid);
    feature_vectors(k,7) = pdist([region_center; hypo_centroid]);
end

