function [ combined_img ] = display_anatomy( original_img, od_img, vessel_img, x, y )
%x and y = fovea 
    circle_img = plot_circle(x,y,10, size(original_img,2), size(original_img,1));
    circle_img = bwperim(circle_img);
    fovea_colored = display_mask( original_img, circle_img, [0 1 0], 'solid' ); %green
    od_colored  = display_mask(original_img, od_img, [0 1 1], 'solid'); %cyan
    vessels_colored = display_mask(original_img, vessel_img,[1 0 0], 'solid'); %red

    combined_img = fovea_colored;
    for layer = 1:3
        J = combined_img(:,:,layer);
        G = vessels_colored(:,:,layer);
        K = od_colored(:,:,layer);
        J(vessel_img) = G(vessel_img);
        J(od_img) = K(od_img);
        combined_img(:,:,layer) = J;
    end
end

