function [out, prob] = text_class_img(img, prediction_struct)
    desc = class_image_sfta(img);

    [prob,out] = posterior(prediction_struct, desc);
end

function [desc] = class_image_sfta(img)
    desc_temp = sfta(img, 8);
    desc = zeros(1, size(desc_temp, 2));
    
    for i=1:size(desc_temp, 2)
        desc(1, i) = desc_temp(1, i);
    end
end

function [desc] = class_image_lbp(img)
    desc = lbp_c(img);

    final = zeros(1, size(desc, 2) * size(desc, 1));
    final_index = 1;
    for y=1:size(desc, 1)
        for x=1:size(desc, 2)
            final(1, final_index) = desc(y, x);
            final_index = final_index + 1;
        end
    end
end

function [grouping,prob] = class_image_hog(img)
    desc = HOG(img);
    
    final = zeros(1, size(desc, 1));
    final_index = 1;
    for x=1:size(desc, 1)
        final(1, final_index) = desc(x, 1);
        final_index = final_index + 1;
    end
end