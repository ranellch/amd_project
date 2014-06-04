function [finalized] = refine_od(bw_image, vessel_image_in)
    %Get both images to be the same sizes
    bw_image = match_sizing(bw_image, 768, 768);
    vessel_image_in = match_sizing(vessel_image_in, 768, 768);
       
    %Skeletonize the vessel image and then find the endpoints
    vessel_image = bwmorph(vessel_image_in, 'skel', Inf);
    vessel_image = bwmorph(vessel_image, 'endpoints');
    vessel_image = imclearborder(vessel_image);

    %Remove the smaller disconnected regions as they are not likely to be
    %an optic disc
    od_image = imopen(bw_image, strel('disk', 5));

    %Find connected components and mark them as possible optic discs
    CC = bwconncomp(od_image);
    CCPixels = regionprops(CC, 'PixelList');
    
    max_cluster_index = 0;
    max_cluster_vote = 0;
    dilation_step = 2;
    for dil=0:10
        for cluster_index=1:size(CCPixels,1)
            %Get the possible optic disc's as a separate binary images
            possible_od = zeros(size(od_image,1), size(od_image,2));
            for i=1:size(CCPixels(cluster_index,1).PixelList,1)
                x = CCPixels(cluster_index,1).PixelList(i,1);
                y = CCPixels(cluster_index,1).PixelList(i,2);
                possible_od(y,x) = 1;
            end
            
            %Thicken up the optic disc if cannot find any endpoints that
            % ended in the previous possible optic disc region
            if(dil > 0)
                possible_od = bwmorph(possible_od, 'thicken', dil*dilation_step);
            end
            
            %Count the endpoints that end near the possible optici disc
            overlap = (vessel_image & possible_od);
            endpoint_overlap_count = 0;
            for y=1:size(overlap,1)
                for x=1:size(overlap,2)
                    if(overlap(y,x) == 1)
                        endpoint_overlap_count = endpoint_overlap_count + 1;
                    end
                end
            end

            %Keep track of the cluster with the maximum number of endpoints
            if(max_cluster_vote < endpoint_overlap_count)
                max_cluster_vote = endpoint_overlap_count;
                max_cluster_index = cluster_index;
            end
        end
        
        if(max_cluster_index > 0 && max_cluster_vote > 1)
            break;
        end
    end

    %Find the pixels associated with this cluster and draw them out
    finalized = zeros(size(od_image,1), size(od_image,2));
    
    if(max_cluster_index > 0 && max_cluster_vote > 0)
        disp(['Located the optic disc with ', num2str(max_cluster_vote), ' vote(s). Had to thicken: n=', num2str(dil*dilation_step)]);
        for i=1:size(CCPixels(max_cluster_index,1).PixelList,1)
            x = CCPixels(max_cluster_index,1).PixelList(i,1);
            y = CCPixels(max_cluster_index,1).PixelList(i,2);
            finalized(y,x) = 1;
        end
    else
        disp('Unable to locate the optic disc in this image');
    end
end
