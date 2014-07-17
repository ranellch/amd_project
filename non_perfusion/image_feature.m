function [image_vector] = image_feature(img)
    addpath('gabor');
    image_vector = get_fv_gabor(img);
end