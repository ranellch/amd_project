function [grouping] = comb_class_img(subimg, prediction_struct)
    text_desc = text_algorithm(subimg);
    [intensity, variance] = avg_intensity(subimg); 
    
    final_fv = horzcat(text_desc, intensity, variance);
    grouping = predict(prediction_struct, final_fv);
end