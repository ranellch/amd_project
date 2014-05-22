function [img] = get_snaked_img(filename)
    indicies = strfind(filename, '/');
    
    if(~isempty(indicies) > 0)
        filename = substring(filename, indicies(length(indicies)));
    end
    
    img=imread(['snaked/', filename]);
end