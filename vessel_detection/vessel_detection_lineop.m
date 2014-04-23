function [ binary_img ] = vessel_detection_lineop( img )

    addpath('../optic_disk');
    addpath('..');
    addpath(genpath('../Test Set'));
    load('vessel_lineop_classifier.mat', 'vessel_lineop_classifier');
    
    %Apply a gaussian filter to the image
    img = gaussian_filter(img);
    
    %Init the orthogonal line operator class
    lineop_obj = line_operator(15, 8);
    fv_image = zeros(size(img, 2), size(img, 1), 3);
    angle_img = zeros(size(img, 2), size(img, 1), 1);

    disp('Running Line Operator!');

    %Get the line operator feature vector for every pixel value
    for y=1:size(fv_image, 1)
        for x=1:size(fv_image, 2)
            [fv_image(y,x,:), angle_img(y,x)] = lineop_obj.get_fv(img, y, x);
        end

        if(debug == 1 && mod(y, 50) == 0)
            disp(['Rows: ', num2str(y), ' / ', num2str(size(binary_img_gabor, 1))]);
        end
    end

    %normalize the line operator feature vectors
    fv_image = normalize_image_fv(fv_image);

    binary_img_lineop = im2bw(img, 1.0);
    for y=1:size(binary_img_lineop, 1)
        %Run the batched line operator classification
        fv_list = squeeze(fv_image(y,:,:));
        [~, out_lineop] = posterior(vessel_lineop_classifier, fv_list);

        %Write to output image the vessel pixels
        for x=1:size(out_lineop, 1)
            binary_img_lineop(y,x) = out_lineop(x,1);
        end
    end

    disp('Completed Classification with Line Operator!');
    
    binary_img = clean_binary(binary_img_lineop, 0);

end

