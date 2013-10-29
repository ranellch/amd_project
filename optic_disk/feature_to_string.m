function [line] = feature_to_string(image)
    line = lbp_to_string(image);
end

function line = sfta_to_string(img)
    output = sfta(img, 8);
    if size(output, 2) > 0
        line = num2str(output(1));
        for x=2:size(output, 2)
            line = [line, ',', num2str(output(x))];
        end
    end
end


function line = hog_to_string(image)
    H=HOG(image);
    line = '';
    if size(H, 1) > 0
        line = [line, num2str(H(1))];
        for x=2:size(H, 1);
            line = [line, ',', num2str(H(x, 1))];
        end
    end
end

function line = lbp_to_string(img)
    output = lbp_c(img, 4, 8, 'nh');
    
    line=num2str(output(1,1));

    for y=1:size(output, 1)
        x=0;
        if(y == 1)
            x=2;
        else
            x=1;
        end
        
        while(x <= size(output,2))
            line = [line, ',', num2str(output(y, x))];
            x=x+1;
        end
    end
    
end
