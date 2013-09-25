function classify(image)
    load('svm_model.mat', 'SVMstruct');

    hogin = HOG(image);
    
    window_size = size(image, 1) / 3;
    
    for y=1:(size(image, 1) - window_size)
        subimage = image(y:y+window_size, 1:window_size);
        hogin = HOG(subimage);
        group = svmclassify(SVMstruct, transpose(hogin));
        disp([num2str(y), ': ', num2str(group)]);
    end
end