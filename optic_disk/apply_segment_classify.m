function [bin_image, prob_matrix] = apply_segment_classify(img, number_of_pixels, text_prediction_struct, int_prediction_struct)
    %Get the number of boxes
    iterations = floor(size(img, 1) / number_of_pixels);
    
    %Get the binary image
    bin_image = zeros(size(img,1), size(img, 2));
    prob_matrix = zeros(iterations, iterations, 4);
    
    %Break the image into grid boxes and classify each box
    for x=1:iterations
        for y=1:iterations
            xs = ((x - 1) * number_of_pixels) + 1;
            if(xs + number_of_pixels > size(img, 2))
                xs = size(img, 2)-number_of_pixels;
            end
            
            ys = ((y - 1) * number_of_pixels) + 1;
            if(ys + number_of_pixels > size(img, 1))
                ys = size(img, 1)-number_of_pixels;
            end
            
            %Get the subimage grid for each part of the subimage
            subimage = img(ys:ys+number_of_pixels,xs:xs+number_of_pixels);
            
            %Classify the subimage based upon breaking it up
            [grouping_text, prob_text] = text_class_img(subimage, text_prediction_struct);
            [grouping_int, ~] = int_class_img(subimage, int_prediction_struct);
                        
            prob_matrix(y,x,1) = grouping_text;
            prob_matrix(y,x,2) = grouping_int;
            prob_matrix(y,x,3) = prob_text(1);
            prob_matrix(y,x,4) = prob_text(2);
            
            %Depending on the classification 
            if grouping_int == 1
                bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 1);
            else
                bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 0);
            end
        end
    end
    
end

function output = apply_bin_to_arr(output, ys, xs, number_of_pixels, val)
    for y=ys:ys+number_of_pixels
        for x=xs:xs+number_of_pixels
            output(y, x) = val;
        end
    end
end
