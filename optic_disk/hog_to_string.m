function line = hog_to_string(image)
    H=HOG(image);
    line = '';
    if size(H) > 0
        line = [line, num2str(H(1))];
        for x=2:size(H);
            line = [line, ',', num2str(H(x))];
        end
    end
end