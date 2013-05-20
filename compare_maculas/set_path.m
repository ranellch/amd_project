function [ path ] = set_path( folder, data_type)
%SET_PATH

    if (exist(folder,'dir') == 7)
        info = what(folder);
        path = fullfile(info.path, data_type);
    else
        path = data_type;
    end

end

