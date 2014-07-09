function [ Iout ] = display_mask( I, mask, color, varargin )
%Places semi-transparent red tint over image I at locations given by mask
%If a solid mask is desired, use 'solid' argument, and make color a three
%element vector specifying [r,g,b] values

    if nargin == 4
        solid = varargin{1};
    end
    
    if strcmp(solid,'solid')
        Ir = I;
        Ig = I;
        Ib = I;
        Ir(mask) = color(1);
        Ig(mask) = color(2);
        Ib(mask) = color(3);
        Iout = cat(3,Ir,Ig,Ib);
    else
    [Iind,map] = gray2ind(I,256);
    Irgb=ind2rgb(Iind,map);
    Ihsv = rgb2hsv(Irgb);
    hueImage = Ihsv(:,:,1);
    satImage = Ihsv(:,:,2);
    if strcmp(color,'purple')
        hueImage(mask==1) = 0.88;    
        satImage(mask==1) = 0.85; 
    else 
        hueImage(mask==1) = 0.011; %red   
        satImage(mask==1) = 0.8; 
    end
    Ihsv(:,:,1) = hueImage;
    Ihsv(:,:,2) = satImage;
    Iout = hsv2rgb(Ihsv);
    end


end

