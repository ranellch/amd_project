function [bin_image] = apply_segment_classify(img, number_of_pixels, text_od_struct, int_od_struct, comb_od_struct)
    %Get the number of boxes
    iterations = floor(size(img, 1) / number_of_pixels);
    
    %Get the binary image
    bin_image = zeros(size(img,1), size(img, 2));
    text_image = zeros(size(img,1), size(img, 2));
    int_image = zeros(size(img,1), size(img, 2));
    
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
            [grouping_text, ~] = text_class_img(subimage, text_od_struct);
            [grouping_int, ~] = int_class_img(subimage, int_od_struct);
            [grouping_total] = comb_class_img(subimage, comb_od_struct);            
            
            text_image = apply_bin_to_arr(text_image, ys, xs, number_of_pixels, grouping_text);
            int_image = apply_bin_to_arr(int_image, ys, xs, number_of_pixels, grouping_int);
            
            %Depending on the classification 
            if grouping_total == 1
                bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 1);
            else
                bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 0);
            end
        end
    end
    
    figure(2), imshowpair(text_image, img);
    figure(3), imshow(int_image, img);
end

function output = apply_bin_to_arr(output, ys, xs, number_of_pixels, val)
    for y=ys:ys+number_of_pixels
        for x=xs:xs+number_of_pixels
            output(y, x) = val;
        end
    end
end
