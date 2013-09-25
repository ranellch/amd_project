function classify(image)
    load('svm_model.mat', 'SVMstruct');
<<<<<<< HEAD
=======

    hogin = HOG(image);
>>>>>>> 7b886adbce1f95659ba8b11644fe8d1bb35ca30d
    
    window_size = size(image, 1) / 3;
    
    for y=1:(size(image, 1) - window_size)
        subimage = image(y:y+window_size, 1:window_size);
        hogin = HOG(subimage);
        group = svmclassify(SVMstruct, transpose(hogin));
        disp([num2str(y), ': ', num2str(group)]);
    end
end