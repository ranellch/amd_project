function [grouping] = comb_class_img(fv, prediction_struct)
    grouping = predict(prediction_struct, fv);
end