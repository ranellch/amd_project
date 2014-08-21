function [ feature_vectors ] = get_fv_hyper(lc,Al,hypo,corrected_img)
%Returns instance matrix of length numclusters(lc) in order of lc labeling

numclusters = max(lc(:));

feature_vectors = zeros(numclusters,8);
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
    mindiff = Inf;
    for i = 1:length(adjacents)
        diff = feature_vectors(k,1) - mean(corrected_img(lc == adjacents(i)));
        if diff > maxdiff
            maxdiff = diff;
        end
        if diff < mindiff
            mindiff = diff;
        end
        s = s+sum(corrected_img(lc == adjacents(i)));
        n = n+numel(corrected_img(lc == adjacents(i)));
    end
    feature_vectors(k,5) = maxdiff;
    feature_vectors(k,6) = mindiff;
    feature_vectors(k,7) = feature_vectors(k,1) - s/n; %average difference
    %get distance from nearest hypo
    region_center = regionprops(region,'Centroid');
    region_center = round(region_center.Centroid);
    rx = region_center(1);
    ry = region_center(2);
    if numel(hypo) > 2
        [y,x] = find(hypo);
        distmatrix = sqrt((y-ry).^2+(x-rx).^2);
        feature_vectors(k,8) = min(distmatrix(:));
    else
         feature_vectors(k,8) = pdist([hypo;region_center]); %use fovea if no hypo
    end
end

