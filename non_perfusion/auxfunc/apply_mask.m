function [results] = apply_mask(img, mask, posval)
    results = img;
    for y=1:size(img,1)
        for x=1:size(img,2)
            if(mask(y,x) ~= posval)
                results(y,x) = 0;
            end
        end
    end
end