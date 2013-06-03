function [ p, img2 ] = point_match( img2, p)
%point_match: Find shifted, scaled, and rotated coordinates of fovea and optic disk in an FAF image given 2
%vessel bifurcation points, and the coordinates of the corresponding points
%in a previous image
%point_match(img2,p), where p is the structure containing all points of
%interest in fields: fovea1, fovea2, optic1, optic2, bifurs1 (2 by 2), and bifurs2 (2 by 2), returns p with offset points and rotated img2 


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
    
    % put img2's bifurcation points in polar coordinates with origin at
    % center
    centerx = size(img2,2)/2;
    centery = size(img2,1)/2;
    
    r1 = pdist([p.bifurs2(1,:); centerx centery]);
    rho1 = atan2d((centery - p.bifurs2(1,2)),(p.bifurs2(1,1)-centerx));% ***y is indexed from top border for images
    r2 = pdist([p.bifurs2(2,:); centerx centery]);
    rho2 = atan2d((centery - p.bifurs2(2,2)),(p.bifurs2(2,1)-centerx));
    
    % rotate around center
    img2  = imrotate(img2, alpha);
    centerx = size(img2,2)/2;
    centery = size(img2,1)/2;
    
    %get coordinates of rotated bifurcation points in img2 ***index: 1=x, 2=y***
    
    rotbif1 = [];
    rotbif2 = [];
    rotbif1(1) = r1*cosd(rho1+alpha)+centerx;
    rotbif1(2) = centery - r1*sind(rho1+alpha); 
    rotbif2(1) = r2*cosd(rho2+alpha)+centerx;
    rotbif2(2) = centery - r2*sind(rho2+alpha);
    
    b = pdist([rotbif1; rotbif2])
    
    % get scalefactor and offsets
    scalefactor = b/a;
    xoffset  = mean([rotbif1(1) - p.bifurs1(1,1)*scalefactor, rotbif2(1) - p.bifurs1(2,1)*scalefactor])
    yoffset = mean([rotbif1(2) - p.bifurs1(1,2)*scalefactor, rotbif2(2) - p.bifurs1(2,2)*scalefactor])
    
    %new fovea and optic disk coordinates
    p.fovea2(1) = round(p.fovea1(1)*scalefactor + xoffset);
    p.fovea2(2) = round(p.fovea1(2)*scalefactor + yoffset);
    p.optic2(1) = round(p.optic1(1)*scalefactor + xoffset);
    p.optic2(2) = round(p.optic1(2)*scalefactor + yoffset);
end

