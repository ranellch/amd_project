function [mask] = create_angle_filter(size) 
mask = zeros(size);
if mod(size,2) == 1
    [xcorr, ycorr] = meshgrid(-floor(size/2):floor(size/2),floor(size/2):-1:-floor(size/2));
else
    [xcorr, ycorr] = meshgrid(-size/2+1:size/2,size/2-1:-1:-size/2);
end
 for y = 1:size
    for x = 1:size
        if sqrt(xcorr(y,x)^2+ycorr(y,x)^2) > floor(size/3)
         mask(y,x) = atan2d(ycorr(y,x),xcorr(y,x));
        end
    end
 end
  mask=mod(mask,180);
end