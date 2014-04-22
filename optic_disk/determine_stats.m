function [ output_results ] = determine_stats( calced_img, vessel_image, pid, time )        

        output_results = zeros(1,8);

        %Get the image traced by hand      
        super_img = imread(vessel_image);
        total_positive_count = 0;
        total_negative_count = 0;
        for y=1:size(super_img,1)
            for x=1:size(super_img,2)
                if(super_img(y,x) == 1)
                    total_positive_count = total_positive_count + 1;
                else
                    total_negative_count = total_negative_count + 1;
                end
            end
        end

        %Check the sizing of the images compared to each other
        if(size(calced_img, 1) ~= size(super_img, 1) || size(calced_img, 2) ~= size(super_img, 2))
            disp(['Images Not Same Size: ', pid, ' - ', time]);
            disp([num2str(size(super_img, 1)), ',', num2str(size(super_img, 2)), ' : ', num2str(size(calced_img, 1)), ',', num2str(size(calced_img, 2))]);
            return;
        end

        %Get some statistics about the quality of the pixel classification
        %for each classifier
        total_count = 0;
        true_positive = 0;
        true_negative = 0;
        false_positive = 0;
        false_negative = 0;
        for y=1:size(calced_img,1)
            for x=1:size(calced_img,2)
                if(super_img(y,x) == 1 && calced_img(y,x) == 1)
                    true_positive = true_positive + 1;
                elseif(super_img(y,x) == 0 && calced_img(y,x) == 0)
                    true_negative = true_negative + 1;
                elseif(super_img(y,x) == 0 && calced_img(y,x) == 1)
                    false_positive = false_positive + 1;
                elseif(super_img(y,x) == 1 && calced_img(y,x) == 0)
                    false_negative = false_negative + 1;
                end
                total_count = total_count + 1;
            end
        end
        
        if(total_count ~= (total_negative_count + total_positive_count))
            disp(['total_count (', num2str(total_count),') and total_negative + total_positive_count (', num2str(total_negative_count + total_positive_count),') Do not match']);
            return;
        end

        output_results(1) = true_positive;
        output_results(2) = true_negative;
        output_results(3) = false_positive;
        output_results(4) = false_negative;
        output_results(5) = total_positive_count;
        output_results(6) = total_negative_count;
        output_results(7) = (true_positive+true_negative)/(total_positive_count+total_negative_count); %accuracy
        output_results(8) = true_positive/(true_positive+false_positive); %precision
        


end

