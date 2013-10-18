function [x,y] = iterate_segments(filename, img, shift, num_of_pixels, nb_cutoff, text_prediction_struct, int_prediction_struct)
    %Gets the bin values in decsending order of magnitude
    bins=sort(unique(shift));

    %Get the image to hold binary data
    iout=im2bw(zeros(size(shift)));

    possible_matches = 1;
    
    for b=1:length(bins)    
        %This img is for visualization purposes only
        rgbImage = cat(3, shift, shift, shift);

        %Get only three clustered regions of intenstiy at a time
        for ycor=1:size(shift, 1)
            for xcor=1:size(shift,2)
                if(shift(ycor,xcor) == bins(b))
                    iout(ycor, xcor) = 1;
                    rgbImage(ycor,xcor,2) = 100;
                else
                    iout(ycor, xcor) = 0;
                end
            end
        end

        
        imwrite(rgbImage,['testing/', num2str(b), '_0_patch.jpg']);
        
        %Find the number of connected regions and their centroids
        CC=bwconncomp(iout);
        S=regionprops(CC,'Centroid');

        %build a window to do more refiend segmentation
        wind = size(img, 1) / 3;

        %Get the centroids for each one of these bad boys
        for i=1:length(S)
            x=S(i).Centroid(1);
            y=S(i).Centroid(2);

            sx = round(x - (wind / 2));
            ex = sx + wind;
            if(sx <= 0) 
                sx = 1;
            end
            if(ex > size(img, 2))
                ex = size(img, 2);
            end

            sy = round(y - (wind / 2));
            ey = sy + wind;
            if(sy <= 0)
                sy = 1;
            end
            if(ey > size(img, 1))
                ey = size(img, 1);
            end

            %Get the subimage surrounded by the segment
            subimage = img(sy:ey,sx:ex);
            
            imwrite(subimage,['testing/', num2str(b), '_', num2str(i), '_subimage.jpg']);

            %Apply the segment classification algorithm
            [classed_img, prob_matrix] = apply_segment_classify(subimage, num_of_pixels, text_prediction_struct, int_prediction_struct);
            
            %Find the count of the high probability boxes
            count_high_prob = 0;
            for x=1:size(prob_matrix, 1)
                for y=1:size(prob_matrix, 2)
                    if(prob_matrix(y,x,1) == 1)
                        count_high_prob = count_high_prob + 1;
                    end
                end
            end
            
            %Are there any high probability squares with similar texture
            if(count_high_prob > 1)
                figure(possible_matches), imshowpair(classed_img, subimage), title([num2str(b), '-', num2str(i), '-classed']);
                possible_matches=possible_matches+1;
            end
        end
    end
end

function [percentage_disc] = check_against_snake(filename, sx, ex, sy, ey)
    %From the filename get the snaked image
    snaked_img = get_snaked_img(filename);

    %Get the snaked img and see if optic disk is in this window
    subimg_snake = snaked_img(sy:ey,sx:ex);

    %Get the sum of the snake img
    sum=0;
    for y=1:size(subimg_snake,1)
        for x=1:size(subimg_snake,2)
            if(subimg_snake(y,x) > 0)
                sum=sum+1;
            end
        end
    end

    %Get the percentage of the window that is consumed by the optic disc
    percentage_disc = sum / (size(subimg_snake,1) * size(subimg_snake,2));
end
