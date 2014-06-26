function [results] = apply_roi_mask(img, mask)
    results = img;
    for y=1:size(img,1)
        for x=1:size(img,2)
            if(mask(y,x) ~= 1)
                results(y,x) = 0;
            end
        end
    end
end