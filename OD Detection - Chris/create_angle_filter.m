 mask400 = ones(400);
 [xcorr, ycorr] = meshgrid(-199:200,199:-1:-200);
 for y = 1:400
    for x = 1:400
         mask400(y,x) = atan2d(ycorr(y,x),xcorr(y,x));
    end
 end
  mask400=mod(mask400,180);