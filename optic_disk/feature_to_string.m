function [line] = feature_to_string(desc)
    line = mat2str(desc);
    line = strrep(line, ';', ',');
    line = strrep(line, ' ', ',');
    line = strrep(line, '[', '');
    line = strrep(line, ']', '');
end

