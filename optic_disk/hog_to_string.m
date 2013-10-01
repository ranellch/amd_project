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