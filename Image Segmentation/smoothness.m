 function flag = smoothness( region)
        p=imhist(region);
        p=p./numel(region);
        L=length(p);

        [~,mu]=statmoments(p,3);
        
        %calculate smoothness
        varn=mu(2)/(L-1)^2; %normalized variance
        R = 1 - 1/(1+varn);
        flag  = R > .005;
    end