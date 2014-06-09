function [finalized] = refine_od(bw_image, vessel_image_in)
    std_img_size = 768;
    
    if size(bw_image,1) ~= size(vessel_image_in,1) || ...
       size(bw_image,2) ~= size(vessel_image_in,2)
        disp('Input of vessel image and possible optic disc images are not the same size');
        finalized = zeros(1);
        return;
    end
    
    %Skeletonize the vessel image and then find the endpoints
    vessel_image_skr = bwmorph(skeleton(vessel_image_in) > 35, 'skel', Inf);
    [~,exy,~]  = anaskel(vessel_image_skr);
    
    %Build the binary mask of endpoint from the previous algorithms output
    vessel_image = zeros(size(vessel_image_in, 1), size(vessel_image_in,2));
    for i=1:size(exy,2)
        vessel_image(exy(2,i),exy(1,i)) = 1;
    end
    %Remove any end points that occur on the edge of the image
    %vessel_image = imclearborder(vessel_image);

    figure(10), imshowpair(vessel_image_in, vessel_image);
    
    %Find connected components and mark them as possible optic discs
    CC = bwconncomp(bw_image);
    CCPixels = regionprops(CC, 'PixelList');
    
    %Loop over each possible optic disc region
    max_cluster_index = 0;
    max_cluster_vote = 0;
    dilation_step = 10;
    for dil=0:20
        max_cluster_index = 0;
        max_cluster_vote = 0;
        dilation_step_count = 0;
        
        for cluster_index=1:size(CCPixels,1)
            %Get the possible optic disc's as a separate binary images
            possible_od = zeros(size(bw_image,1), size(bw_image,2));
            for i=1:size(CCPixels(cluster_index,1).PixelList,1)
                x = CCPixels(cluster_index,1).PixelList(i,1);
                y = CCPixels(cluster_index,1).PixelList(i,2);
                possible_od(y,x) = 1;
            end
            
            %Thicken up the optic disc if cannot find any endpoints that
            % ended in the previous possible optic disc region
            if(dil > 0)
                possible_od = imdilate(possible_od, strel('disk', dil*dilation_step));
            end
            
            %Count the endpoints that end near the possible optic disc
            overlap = (vessel_image & possible_od);
            endpoint_overlap_count = 0;
            for y=1:size(overlap,1)
                for x=1:size(overlap,2)
                    if(overlap(y,x) == 1)
                        endpoint_overlap_count = endpoint_overlap_count + 1;
                    end
                end
            end

            dilation_step_count = endpoint_overlap_count + 1;
            
            %Keep track of the cluster with the maximum number of endpoints
            if(max_cluster_vote < endpoint_overlap_count)
                max_cluster_vote = endpoint_overlap_count;
                max_cluster_index = cluster_index;
            end
        end
        
        %Break out of thickening loop if total vote count is greater than 4
        if(dilation_step_count > 3)
            break;
        end
    end

    %Find the pixels associated with this cluster and draw them out
    finalized = zeros(size(bw_image,1), size(bw_image,2));
    
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
