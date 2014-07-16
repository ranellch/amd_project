function [image_vector] = image_feature(img)
    run('../vlfeat/toolbox/vl_setup');
    image_vector = get_fv_gabor(img);
end