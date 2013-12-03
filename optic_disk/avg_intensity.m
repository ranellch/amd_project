function [mean, var] = avg_intensity(img)
    %Get the sum and count;
    the_sum = 0.0;
    count = 0;
    for y=1:size(img,1)
        for x=1:size(img,2)
            the_sum = the_sum + double(img(y,x));
            count = count + 1;
        end
    end
    
    %Calculate avg value
    mean = the_sum / double(count);
    
    %calculate the variance
    var = 0.0;
    for y=1:size(img,1)
        for x=1:size(img,2)
            diff = double(img(y,x)) - mean;
            var = var + (diff^2);
        end
    end
end