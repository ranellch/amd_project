function [data_matrix, timing_matrix] = video_feature(paths, times, counter, positive_image, std_img_size)
    %Init the output matricies
    data_matrix = double(zeros(1));
    timing_matrix = double(zeros(1,counter));

    %iterate over all the images
    for k=1:counter
        cur_frame = imread(paths{k});
        
        cur_time = str2double(times{k});
        timing_matrix(1,k) = cur_time;

        disp(['   [FRAME ', num2str(k),'] ', times{k}]);

        %Convert the image to a grayscale image
        if (size(cur_frame, 3) > 1)
            cur_frame = rgb2gray(cur_frame(:,:,1:3));
        end

        %Resize the image and convert to dobule for gaussian filtering and then normalized
        cur_frame = imresize(cur_frame, [std_img_size, NaN]);

        %Calculate the image feature vectors
        cur_frame_feat = image_feature(cur_frame);

        if(k == 1)
            data_matrix = double(zeros(size(cur_frame_feat,1), size(cur_frame_feat,2), counter, size(cur_frame_feat, 3)));
        end

        %Write to ouput the results from the frame interpolation method
        for y=1:size(cur_frame_feat, 1)
            for x=1:size(cur_frame_feat, 2)
                if(positive_image(y,x) == 1)
                    data_matrix(y,x,k,:) = cur_frame_feat(y,x,:);
                end
            end
        end
    end
end