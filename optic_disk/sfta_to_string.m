function line = sfta_to_string(img)
    output = sfta(img, 42);
    if size(output, 2) > 2
        line = num2str(output(1));
        for x=2:size(output, 2)
            line = [line, ',', num2str(output(x))];
        end
    end
end
