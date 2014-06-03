function [finalized] = refine_od(bw_image, vessel_image_in)
    %Get both images to be the same sizes
    bw_image = match_sizing(bw_image, 768, 768);
    vessel_image_in = match_sizing(vessel_image_in, 768, 768);

    %Remove the disconnected regions
    od_image = imopen(bw_image, strel('disk', 5));

    %Find connected componets and mark them as possible optic discs
    CC = bwconncomp(od_image);
    CCCentroid = regionprops(CC, 'Centroid');
       
    %Skeletonize the vessel image and then find the endpoints
    vessel_image = bwmorph(vessel_image_in, 'skel', Inf);
    vessel_image = bwmorph(vessel_image, 'endpoints');
    vessel_image = imclearborder(vessel_image);

    %Find the endpoints the end in the possible optic disc's
    overlap = (vessel_image & od_image);
    overlapped_endpoints = zeros(numel(CCCentroid),1);
    
    for y=1:size(overlap,1)
        for x=1:size(overlap,2)
            if(overlap(y,x) == 1)
                which_cluster = find_closest_centoird(x,y,CCCentroid);
                overlapped_endpoints(which_cluster,1) = overlapped_endpoints(which_cluster,1) + 1;
            end
        end
    end
    
    %Find the cluster with the maximum number of endpoints
    max_cluster = 0;
    max_cluster_index = 0;
    for i=1:size(overlapped_endpoints,1)
        if overlapped_endpoints(i,1) > max_cluster
            max_cluster = overlapped_endpoints(i,1);
            max_cluster_index = i;
        end
    end
    
    %Find the pixels associated with this cluster and draw them out
    finalized = zeros(size(od_image,1), size(od_image,2));
    CCPixels = regionprops(CC, 'PixelList');
    
    for i=1:size(CCPixels(max_cluster_index,1).PixelList,1)
        x = CCPixels(max_cluster_index,1).PixelList(i,1);
        y = CCPixels(max_cluster_index,1).PixelList(i,2);
        finalized(y,x) = 1;
    end
end

function [which_cluster] = find_closest_centoird(x,y,CCCentroid)
    max_distance = 100000000;
    which_cluster = 0;
    
    for i=1:numel(CCCentroid)
        cx = CCCentroid(i,1).Centroid(1,1);
        cy = CCCentroid(i,1).Centroid(1,2);
        euc_dis = sqrt((x-cx).^2 + (y-cy).^2);
        if(euc_dis < max_distance)
            max_distance = euc_dis;
            which_cluster = i;
        end
    end
end