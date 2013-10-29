function [classed_img] = iterate_one_segment(image, num_of_pixels, text_prediction_struct, int_prediction_struct)
        
    %Apply the segment classification algorithm
    [classed_img, prob_matrix] = apply_segment_classify(image, num_of_pixels, text_prediction_struct, int_prediction_struct);

    %Find the count of the high probability boxes
    count_high_prob = 0;
    for x=1:size(prob_matrix, 1)
        for y=1:size(prob_matrix, 2)
            if(prob_matrix(y,x,1) == 1 && prob_matrix(y,x,2) == 1)
                count_high_prob = count_high_prob + 1;
            end
        end
    end

    %Are there any high probability squares with similar texture
    if(count_high_prob > 1)
        
    end
    
    imshowpair(classed_img, image);
end