function [x, y, theta] = align_images(base_optic_x, base_optic_y, base_macula_x, base_macula_y,...
                                             next_optic_x, next_optic_y, next_macula_x, next_macula_y)
	base_optic_x = str2double(base_optic_x);
    base_optic_y = str2double(base_optic_y);
    base_macula_x = str2double(base_macula_x);
    base_macula_y = str2double(base_macula_y);
    
    next_optic_x = str2double(next_optic_x);
    next_optic_y = str2double(next_optic_y);
    next_macula_x = str2double(next_macula_x);
    next_macula_y = str2double(next_macula_y);
    
    x = next_optic_x - base_optic_x;
    y = next_optic_y - base_optic_y;
    
    
end
