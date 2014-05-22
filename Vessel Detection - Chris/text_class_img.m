function [out, prob] = text_class_img(fv, prediction_struct)
    [prob,out] = posterior(prediction_struct, fv);
end

