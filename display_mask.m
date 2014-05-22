function [ Iout ] = display_mask( I, mask )
%Places semi-transparent red tint over image I at locations given by mask    

    [Iind,map] = gray2ind(I,256);
    Irgb=ind2rgb(Iind,map);
    Ihsv = rgb2hsv(Irgb);
    hueImage = Ihsv(:,:,1);
    hueImage(mask==1) = 0.011; %red
    Ihsv(:,:,1) = hueImage;
    satImage = Ihsv(:,:,2);
    satImage(mask==1) = .8; %semi transparent
    Ihsv(:,:,2) = satImage;
    Iout = hsv2rgb(Ihsv);


end

