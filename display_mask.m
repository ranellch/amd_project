function [ Iout ] = display_mask( I, mask, color )
%Places semi-transparent red tint over image I at locations given by mask    

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

