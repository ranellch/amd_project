function [path] = get_snaked_path(filename)
    indicies = strfind(filename, '/');
    
    if(~isempty(indicies) > 0)
        filename = filename(indicies(length(indicies)) + 1:length(filename));
    end
    
    path = (['Labeled/AMD Snaked/', filename]);
    
    if ispc ~= 1
       path = strrep(path, '\', '/');
    end
end