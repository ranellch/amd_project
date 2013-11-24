function [vector] = text_algorithm(img)
    vector = image_sfta(img);
end

function [final] = image_sfta(img)
    desc = sfta(img, 8);
    final = zeros(1, size(desc, 2));
    
    for i=1:size(desc, 2)
        final(1, i) = desc(1, i);
    end
end

function [final] = image_lbp(img)
    desc = lbp(img);
    
    final = zeros(1, size(desc, 2) * size(desc, 1));
    final_index = 1;
    for y=1:size(desc, 1)
        for x=1:size(desc, 2)
            final(1, final_index) = desc(y, x);
            final_index = final_index + 1;
        end
    end
end

function [final] = image_hog(img)
    desc = HOG(img);
    
    final = zeros(1, size(desc, 1));
    final_index = 1;
    for x=1:size(desc, 1)
        final(1, final_index) = desc(x, 1);
        final_index = final_index + 1;
    end
end