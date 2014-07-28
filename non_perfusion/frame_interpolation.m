function [x_inter, interpolated_curves] = frame_interpolation(std_img_size, counter, times, paths, positive_image, filename_gabor)
    %Output scatter plot for each pixel
    scatter_plot = double(zeros(1));
    x_values = double(zeros(counter,1));
           
    for k=1:counter
        cur_frame = imread(paths{k});
        x_values(k,1) = str2double(times{k});

        disp(['   [FRAME ', num2str(k),'] ', times{k}]);

        %Convert the image to a grayscale image
        if (size(cur_frame, 3) > 1)
            cur_frame = rgb2gray(cur_frame(:,:,1:3));
        end

        %Resize the image and convert to dobule for gaussian filtering and then normalized
        cur_frame = imresize(cur_frame, [std_img_size, NaN]);

        %Calculate the image feature vectors
        cur_frame_feat = image_feature(cur_frame);

        %If first iteration then build the scatter plot array
        if(k == 1)
            scatter_plot = double(zeros(size(cur_frame_feat, 1), size(cur_frame_feat, 2), counter, size(cur_frame_feat, 3)));
        end

        %Copy results into the interpolation array
        for y=1:size(cur_frame_feat,1)
            for x=1:size(cur_frame_feat,2)
            	scatter_plot(y,x,k,:) = cur_frame_feat(y,x,:);
            end
        end
        
        if(k == 0)
            break;
        end
    end
    
    save(filename_gabor, 'scatter_plot');
    save('x_values.mat','x_values');
    
    [x_inter, interpolated_curves] = interpolate_time_curves(0.1, x_values, scatter_plot, positive_image);
end