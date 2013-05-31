function [ p, img2 ] = point_match( img2, p)
%point_match: Find shifted, scaled, and rotated coordinates of fovea and optic disk in an FAF image given 2
%vessel bifurcation points, and the coordinates of the corresponding points
%in a previous image
%point_match(img2,p), where p is the structure containing all points of
%interest in fields: fovea1, fovea2, optic1, optic2, bifurs1, and bifurs2, returns p with offset points and rotated img2 


    %image 1
    a = pdist(p.bifurs1)

    y1 = abs(p.bifurs1(1,2)  - p.bifurs1(2,2)); 
    x1  = abs(p.bifurs1(1,1)  - p.bifurs1(2,1));
    theta = atand(y1/x1);

    %image 2
    y2 = abs(p.bifurs2(1,2)  - p.bifurs2(2,2)); 
    x2  = abs(p.bifurs2(1,1)  - p.bifurs2(2,1));
    phi = atand(y2/x2);
    
    alpha =  theta - phi % offset angle in degrees

    img2  = imrotate(img2, alpha);
    
    %rotated bifurcation points
    
    r1 = pdist([p.bifurs2(1,:); 0 0]);
    r2 = pdist([p.bifurs2(2,:);0 0]);
    rotbif1 = [r1*cosd(theta) r1*sind(theta)];
    rotbif2 = [r2*cosd(theta) r2*sind(theta)];
    
    b = pdist([rotbif1; rotbif2])
 
    scalefactor = b/a;
    xoffset  = mean([rotbif1(1) - p.bifurs1(1,1)*scalefactor, rotbif2(1) - p.bifurs1(2,1)*scalefactor]);
    yoffset = mean([rotbif1(2) - p.bifurs1(1,2)*scalefactor, rotbif2(2) - p.bifurs1(2,2)*scalefactor]);
    
    %new fovea and optic disk coordinates
    p.fovea2(1)  = p.fovea1(1)  - xoffset;
    p.fovea2(2) = p.fovea1(2) - yoffset;
    p.optic2(1) = p.optic1(1) - xoffset;
    p.optic2(2) = p.optic2(2) - yoffset;
end

