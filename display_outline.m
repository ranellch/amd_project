function [ Iout ] = display_outline( I, mask, color)
% make color a three
%element vector specifying [r,g,b] values
        outline = bwperim(mask);
		if size(I,3) > 1
			Ir = I(:,:,1);
			Ig = I(:,:,2);
			Ib = I(:,:,3);
		else 
			Ir = I;
			Ig = I;
			Ib = I;
		end
        Ir(outline) = color(1);
        Ig(outline) = color(2);
        Ib(outline) = color(3);
        Iout = cat(3,Ir,Ig,Ib);
end

