function line = lbp_to_string(img)
    output = lbp(img, 1, 8, 'h');
    if size(output, 2) > 2
        line = num2str(output(1));
        for x=2:size(output, 2)
            line = [line, ',', num2str(output(x))];
        end
    end
end