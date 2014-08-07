function [image_vector_final] = image_feature(img)
    addpath('gabor');
    
    img = im2double(img);
    img = gaussian_filter(img);
    img = zero_m_unit_std(img);
    
    image_vector_final = double(zeros(size(img,1), size(img,2), 6));
    
    image_vector_final(:,:,1:5) = get_fv_gabor(img);
    image_vector_final(:,:,6) = imfilter(img, ones(3) / 9);
end