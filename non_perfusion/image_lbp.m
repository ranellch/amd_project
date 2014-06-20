function [feature_vector, label_vector] = image_lbp(img, mask)
    %Calculate the LBP on the input image
    cellsize = 6;
    lbpout = vl_lbp(single(img), cellsize);
    
    %Create vectors for handling the results
    feature_vector = zeros(size(lbpout,1)*size(lbpout,2), size(lbpout,3) + 1);
    label_vector = zeros(size(lbpout,3), 1);
    count = 1;
    
    for y=1:size(lbpout,1)
        for x=1:size(lbpout,2)
            %Get the label from the mask
            subimage = mask((((y-1)*cellsize+1)):((y*cellsize )), (((x-1)*cellsize)+1):((x*cellsize)));
            pos = sum(subimage(:) == 1);
            if((pos / (cellsize*cellsize)) > .8)
                group = 1;
            else
                group = 0;
            end
            label_vector(count,1) = group;
            
            %Get the feature vector in the correct format
            feature_vector(count, 1:end-1) = lbpout(y,x,:);
            feature_vector(count, end) = mean2(subimage);
           
            count = count + 1;
        end
    end
end