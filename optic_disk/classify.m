function classify(image)
    load('svm_model.mat', 'SVMstruct');
    
    maxy = size(image, 1);
    window_size = maxy / 3;
    
    %Go down the left side of the image
    for y=window_size:(maxy - window_size)
        subimage = image(y:y+window_size, 1:window_size);
        hogin = HOG(subimage);
        group = svmclassify(SVMstruct, transpose(hogin));
        disp([num2str(y), ': ', num2str(group)]);
    end
    
    %Go down the right side of the image
    for y=window_size:(maxy - window_size)
        subimage = image(y:y+window_size, size(image, 1) - window_size:size(image, 2));
        hogin = HOG(subimage);
        group = svmclassify(SVMstruct, transpose(hogin));
        disp([num2str(y), ': ', num2str(group)]);
    end
end