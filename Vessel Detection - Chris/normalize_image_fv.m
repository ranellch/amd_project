function [iout] = normalize_image_fv(img)
    %Declare variables for calculating mean
    summation = zeros(size(img, 3), 1);
    count = zeros(size(img, 3), 1);
    
    %Get summation for each feature value
    for fv=1:size(img,3)
        for y=1:size(img, 1)
            for x=1:size(img,2)
                summation(fv,1) = summation(fv,1) + img(y,x,fv);
                count(fv,1) = count(fv,1) + 1;
            end
        end
    end

    %Calculate the mean for each level
    mean = zeros(size(img, 3), 1);
    for fv=1:size(mean,1)
        mean(fv,1) = double(summation(fv,1)) / double(count(fv,1));
    end
    
    %Declare variavles for calculating variance
    variance = zeros(size(img,3),1);
    
    %Get variance summation
    for fv=1:size(img,3)
        for y=1:size(img, 1)
            for x=1:size(img,2)
                variance(fv,1) = variance(fv,1) + ((mean(fv,1) - double(img(y,x,fv)))^2);
            end
        end
    end
    
    %Calculate the standard deviation for each feature
    stddev = zeros(size(img, 3), 1);
    for sd=1:size(stddev,1)
        stddev(sd,1) = sqrt(variance(sd,1) / double(count(sd,1)));
    end
    
    %Normalize the feature vectors
    iout = img;
    for fv=1:size(img,3)
        for y=1:size(img, 1)
            for x=1:size(img,2)
                iout(y,x,fv) = (double(img(y,x,fv)) - mean(fv,1)) / stddev(fv,1);
            end
        end
    end
end