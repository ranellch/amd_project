function [proc2] = scale_intensities(img1, img2, fov, opt)
 % Performs least squares fitting to get coefficient that scales pixel intensities of img2 to img1
    
 img_sz = size(img1);
 
 start = sqrt((opt(1)-fov(1))^2+(opt(2)-fov(2))^2)*.5;
 limit = sqrt((opt(1)-fov(1))^2+(opt(2)-fov(2))^2)*.8;
 step = (limit-start)/20;
 
 
 sampls1 = zeros(20,1);
 sampls2 = zeros(20,1);
 
 
    [xgrd, ygrd] = meshgrid(1:img_sz(2), 1:img_sz(1));   
    x = xgrd - fov(1);    % offset the origin
    y = ygrd - fov(2);

    
 % Create sampling rings 
 for i=1:20

    ro=start+step*i;
    ob = x.^2 + y.^2 <= ro.^2; %outer bound   
    ri=start+step*(i-1);
    ib = x.^2 + y.^2 >= ri.^2; %inner bound
    ring = logical(ib.*ob);
    
    sampls1(i) = mean(img1(ring));
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
    