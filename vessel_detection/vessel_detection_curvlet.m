function [out] = vessel_detection_curvlet(I)
    I = rgb2gray(I);

    height = size(I,1);
    width = size(I,2);
    
    border_clear = 10;
    for y=1:height
        for x=1:width
            if((y <= border_clear || y >= (height - border_clear)) || ...
               (x <= border_clear || x >= (width - border_clear)))
                I(y, x) = 255;
            end
        end
    end
    
    %Get all the unique values in this image
    unique_values_sorted = unique(I(:));
    total_count_one_percent = height * width * 0.01;
    
    %Calculate the number of values in the one percent
    one_percent_image = zeros(height, width);
    our_total_count = 0;
    i = 1;
    while our_total_count < total_count_one_percent && i <= length(unique_values_sorted)
        for y=1:height
            for x=1:width
                if(I(y, x) == unique_values_sorted(i))
                    one_percent_image(y, x) = 1;
                    our_total_count = our_total_count + 1;
                end
            end
        end
        
        i=i+1;
    end
    
    zero_four_percent = round(height * width * 0.0004);
    open_zero_four = bwareaopen(one_percent_image, zero_four_percent);
    open_zero_four = bwmorph(open_zero_four, 'diag');
    open_zero_four = bwmorph(open_zero_four, 'fill');
    open_zero_four = imclose(open_zero_four, strel('disk',4));
        
    imshow(open_zero_four);
    
    %Find the centroid of each connected cluster
    count = 0;
    for y=1:height
        for x=1:width
            if(open_zero_four(y, x) == 1)
                count = count + 1;
            end
        end
    end
    
    X = zeros(count, 2);
    index = 1;
    for y=1:height
        for x=1:width
            if(open_zero_four(y, x) == 1)
                X(index, 1) = x;
                X(index, 2) = y;
                index = index + 1;
            end
        end
    end
    
    cc = bwconncomp(open_zero_four);
    if(cc.NumObjects > 0)
        [indx, ctrs] = kmeans(X, cc.NumObjects);
        disp(ctrs);
        disp(['The algorthim detected ', num2str(cc.NumObjects), ' clusters']);
    end
    
    
    
    %Fix illumination
    %u(x,y) = I(x,y) - k1*L(x,y) / k2*C(x,y)-
    %L and C calculated using non uniform sampling grid shown in figure 2
    %    At each point in the sampling grid a WxW window is use to calculate the 
    %    the mean and sigma at each point window in the image.
    %Then for each pixel in the image a Mahalanobis distance is calcuated to check
    %    to see if a pixel belongs to the background or not
    

   
end


