function [proc2] = scale_intensities(img1, fov1, opt1, img2, fov2, opt2)
 % Performs least squares fitting to get coefficient that scales pixel intensities of img2 to img1
    
 img_sz1 = size(img1);
 img_sz2 = size(img2);
 
 start1 = sqrt((opt1(1)-fov1(1))^2+(opt1(2)-fov1(2))^2)*.5;
 limit1 = sqrt((opt1(1)-fov1(1))^2+(opt1(2)-fov1(2))^2)*.8;
 step1 = (limit1-start1)/20;
 
 
 
 start2 = sqrt((opt2(1)-fov2(1))^2+(opt2(2)-fov2(2))^2)*.5;
 limit2 = sqrt((opt2(1)-fov2(1))^2+(opt2(2)-fov2(2))^2)*.8;
 step2 = (limit2-start2)/20;
 
 
 sampls1 = zeros(20,1);
 sampls2 = zeros(20,1);
 
 
    [xgrd1, ygrd1] = meshgrid(1:img_sz1(2), 1:img_sz1(1));   
    x1 = xgrd1 - fov1(1);    % offset the origin
    y1 = ygrd1 - fov1(2);
    
    [xgrd2, ygrd2] = meshgrid(1:img_sz2(2), 1:img_sz2(1));   
    x2 = xgrd2 - fov2(1);    % offset the origin
    y2 = ygrd2- fov2(2);
    
 % Create sampling rings 
 for i=1:20

    ro=start1+step1*i;
    ob = x1.^2 + y1.^2 <= ro.^2; %outer bound   
    ri=start1+step1*(i-1);
    ib = x1.^2 + y1.^2 >= ri.^2; %inner bound
    ring = logical(ib.*ob);
    
    sampls1(i) = mean(img1(ring));
    
    
    
    ro=start2+step2*i;
    ob = x2.^2 + y2.^2 <= ro.^2; %outer bound
    ri=start2+step2*(i-1);
    ib = x2.^2 + y2.^2 >= ri.^2; %inner bound
    ring = logical(ib.*ob);
    
    sampls2(i) = mean(img2(ring));
    
    
 end
    % Calculate scaling factors b1 & b2 (y=b1x+b2)
    
    b = lsqnonneg(sampls2,sampls1);
    if length(b)==2
        proc2 = img2*b(1) +b(2);
    else
        proc2 = img2*b(1);
    end
end
    