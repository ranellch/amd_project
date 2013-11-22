function [out, prob] = text_class_img(img, prediction_struct)
    desc = text_algorithm(img);

    [prob,out] = posterior(prediction_struct, desc);
end

