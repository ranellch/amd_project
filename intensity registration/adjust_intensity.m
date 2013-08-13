function [Iout, cps] = adjust_intensity(I, baseimg)
%use control points on vessels to scale intensities of seperate image
%sections


cps  = detect_vessels(baseimg);

tform = lsqnonneg(double(I(cps)),double(baseimg(cps)));

    if length(tform)==2
        Iout = I*tform(1) +tform(2);
    else
        Iout = I*tform(1);
    end
    
Iout = uint8(Iout);


end







        
        
        

