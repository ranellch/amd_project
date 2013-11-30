function [bin_image] = apply_segment_classify(img, number_of_pixels, text_od_struct, int_od_struct, comb_od_struct, debug)
    %Get the number of boxes
    iterations = floor(size(img, 1) / number_of_pixels);
    
    %Get the binary image
    bin_image = zeros(size(img,1), size(img, 2));
    text_image = zeros(size(img,1), size(img, 2));
    int_image = zeros(size(img,1), size(img, 2));
    
    total_iter = iterations^2;
    cur_iter = 0;
    
    fv_img = zeros(iterations, iterations, 26);
    box_coord = zeros(iterations, iterations, 2);
    
    if(debug == 1)
        disp('Building Image Feature Vectors!');
    end
    
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
            si = img(ys:ys+number_of_pixels,xs:xs+number_of_pixels);

            %Construct the texture vector for this subimage
            [m,v] = avg_intensity(si);
            fv_img(y, x, :) = horzcat(text_algorithm(si), m, v);
            box_coord(y,x,1) = xs;
            box_coord(y,x,2) = ys;
            
            cur_iter=cur_iter+1;
            if(debug == 1 && mod(cur_iter, 500) == 0)
                disp(['Box: ', num2str(cur_iter), ' / ', num2str(total_iter)]);
            end
        end
    end
    
    for x=1:iterations
        for y=1:iterations
            %Get the current boxes featrue vector
            fv = transpose(squeeze(fv_img(y,x,:)));
            
            %Classify the subimage based upon breaking it up
            %[grouping_text, ~] = text_class_img(fv(1:24), text_od_struct);
            %[grouping_int, ~] = int_class_img(fv(25:26), int_od_struct);
            [grouping_total] = comb_class_img(fv, comb_od_struct);    
                        
            %text_image = apply_bin_to_arr(text_image, box_coord(y,x,2), box_coord(y,x,1), number_of_pixels, grouping_text);
            %int_image = apply_bin_to_arr(int_image, box_coord(y,x,2), box_coord(y,x,1), number_of_pixels, grouping_int);
            
            %Depending on the classification 
            if grouping_total == 1
                bin_image = apply_bin_to_arr(bin_image, box_coord(y,x,2), box_coord(y,x,1), number_of_pixels, 1);
            else
                bin_image = apply_bin_to_arr(bin_image, box_coord(y,x,2), box_coord(y,x,1), number_of_pixels, 0);
            end
        end
    end
    
    if(debug == 1)
        figure(2), imshowpair(text_image, img);
        figure(3), imshowpair(int_image, img);
    end
end

function output = apply_bin_to_arr(output, ys, xs, number_of_pixels, val)
    for y=ys:ys+number_of_pixels
        for x=xs:xs+number_of_pixels
            output(y, x) = val;
        end
    end
end
