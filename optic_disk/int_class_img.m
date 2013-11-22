function [out, prob] = int_class_img(img, prediction_struct)
    [mean_val, var_val] = avg_intensity(img);
    input_arr = zeros(1,2);
    input_arr(1,1) = mean_val;
    input_arr(1,2) = var_val;
    [prob,out] = posterior(prediction_struct, input_arr);
end