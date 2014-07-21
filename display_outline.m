function [ Iout ] = display_outline( I, mask, color)
% make color a three
%element vector specifying [r,g,b] values
        outline = bwperim(mask);
        Ir = I;
        Ig = I;
        Ib = I;
        Ir(outline) = color(1);
        Ig(outline) = color(2);
        Ib(outline) = color(3);
        Iout = cat(3,Ir,Ig,Ib);

end

