 mask100 = ones(100);
 [xcorr, ycorr] = meshgrid(-49:50,49:-1:-50);
 for y = 1:100
    for x = 1:100
         mask100(y,x) = atan2d(ycorr(y,x),xcorr(y,x));
    end
 end
  mask100=mod(mask100,180);