function classify(image)
    load('svm_model.mat', 'SVMstruct');
    
    blocks = 5;
    
    maxx = size(image, 2);
    maxy = size(image, 1);
    window_size = round(maxy / blocks);
    
    ystart = round(maxy / 5);
    yend = ystart * 3;
    
    %Go down the left side of the image
    for x=1:(maxx - window_size)
        for y=ystart:yend    
            subimage = image(y:y+window_size,x:x+window_size);
            figure(1);
            imshow(subimage);
            grouping = class_image(subimage, SVMstruct);
            if grouping == 1
                disp([num2str(x), ', ', num2str(y), ': ', num2str(grouping)]);
            end
        end
    end
end

function grouping = class_image(img, SVMstruct)
    %hogin = HOG(img);
    lbpin = lbp(img, 1, 8, 'h');

    final = zeros(1, size(lbpin, 2));
    final_index = 1;
    for x=1:size(lbpin, 2)
        final(1, final_index) = lbpin(1, x);
        final_index = final_index + 1;
    end

    grouping = svmclassify(SVMstruct, final);
    return;
end