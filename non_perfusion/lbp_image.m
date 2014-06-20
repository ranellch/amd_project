function [classimg] = lbp_image(img, classifier, scaling_factors)
    %Calculate the LBP of thin input image
    cellsize = 6;
    lbpout = vl_lbp(single(img), cellsize);
    
    %Create feature vector array
    instance_matrix = zeros(size(lbpout,1) * size(lbpout,2), size(lbpout,3) + 1);
    
    %Get the image subsections and run algorithm upon in.
    count = 1;
    for x=1:size(lbpout,2)
        for y=1:size(lbpout,1)
            subimg = img((((y-1)*cellsize+1)):((y*cellsize)), (((x-1)*cellsize)+1):((x*cellsize)));
                        
            instance_matrix(count, 1:end-1) = lbpout(y,x,:);
            instance_matrix(count, end) = mean2(subimg);
            count = count + 1;
        end
    end
    
    %Scale the vectors for input into the classifier
    for i = 1:size(instance_matrix,2)
        fmin = scaling_factors(1,i);
        fmax = scaling_factors(2,i);
        instance_matrix(:,i) = (instance_matrix(:,i)-fmin)/(fmax-fmin);
    end
    
    %Use classifier on the image!
    predictmask = zeros(size(lbpout,1), size(lbpout,2));
    predictmask(:) = libpredict(ones(length(instance_matrix),1), sparse(instance_matrix), classifier, '-q');
    
    classimg = zeros(size(img,1), size(img,2));
    for y=1:size(predictmask,1)
        for x=1:size(predictmask,2)
            classimg((((y-1)*cellsize+1)):((y*cellsize)), (((x-1)*cellsize)+1):((x*cellsize))) = predictmask(y,x);
        end
    end
end