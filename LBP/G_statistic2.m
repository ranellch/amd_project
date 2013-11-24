function [ G ] = G_statistic2( hist1, hist2 )
%Calculates G statistic of 2 2D histograms

loghist1 = hist1;
loghist1(hist1~=0) = log(hist1(hist1~=0));
loghist2 = hist2;
loghist2(hist2~=0) = log(hist2(hist2~=0));
log1plus2 = hist1+hist2;
log1plus2(log1plus2~=0) = log(log1plus2(log1plus2~=0));

G = 2*(sum(sum(hist1.*loghist1)) + sum(sum(hist2.*loghist2)) - ...
        (sum(sum(hist1))*log(sum(sum(hist1))) +  sum(sum((hist2)))*log(sum(sum(hist2)))) - ...
        sum(sum((hist1+hist2).*log1plus2)) + ...
        (sum(sum(hist1))+sum(sum(hist2)))*log(sum(sum(hist1))+sum(sum(hist2))));

end

