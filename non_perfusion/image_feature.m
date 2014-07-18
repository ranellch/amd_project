function [image_vector] = image_feature(img)
    addpath('gabor');
    
    img = im2double(img);
    img = gaussian_filter(img);
    img = zero_m_unit_std(img);
            
    image_vector = get_fv_gabor(img);
end