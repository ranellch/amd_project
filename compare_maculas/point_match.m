function [ p, img2 ] = point_match( img2, p)
%point_match: Find shifted, scaled, and rotated coordinates of fovea and optic disk in an FAF image given 2
%vessel bifurcation points, and the coordinates of the corresponding points
%in a previous image
%point_match(img2,p) returns modified p, where p is the structure containing all points of
%interest, and rotated img2



    a = pdist(p.bifurs1)

    y1 = abs(p.bifurs1(1,2)  - p.bifurs1(2,2)); 
    x1  = abs(p.bifurs1(1,1)  - p.bifurs1(2,1));
    theta = atand(y1/x1);

    y2 = abs(p.bifurs2(1,2)  - p.bifurs2(2,2)); 
    x2  = abs(p.bifurs2(1,1)  - p.bifurs2(2,1));
    phi = atand(y2/x2);

    alpha =  theta - phi % offset angle in degrees
    
    img2  = imrotate(img2, alpha);
    
    rotbif1 = [p.bifurs2(1,1)*cosd(alpha) p.bifurs2(1,2)*sind(alpha)];
    rotbif2 = [p.bifurs2(2,1)*cosd(alpha) p.bifurs2(2,2)*sind(alpha)];
    
    b = pdist(rotbif1, rotbif2)
 
    scalefactor = b/a;
    xoffset  = mean([rotbif1(1) - p.bifurs1(1,1), rotbif2(1) - p.bifurs1(2,1)])*scalefactor;
    yoffset = mean([rotbif1(2) - p.
    
    p.fovea2  = p.fovea1  - 
end

