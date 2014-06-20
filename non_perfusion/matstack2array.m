function [array] = matstack2array(inarr)
    array = zeros(size(inarr,1)*size(inarr,2),size(inarr,3));
    count = 1;
    for x = 1:size(inarr,2)
        for y = 1:size(inarr,1)
            array(count,:) = inarr(y,x,:);
            count = count + 1;
        end
    end
end
