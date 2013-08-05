function [min] = min_axis(img1, img2, dim)
    min = size(img1, dim);
    
    if(size(img2, dim) < min)
       min =  size(img2, dim);
    end
end