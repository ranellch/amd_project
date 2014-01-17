function [Y, Z, labels] = kms_clustering_vb(G,bandwidths)
% kernel mean shift clustering with variable bandwidth
% USAGE: [Y, Z, labels] = kms_clustering_vb(G,bandwidths)
% 
% Input: 
%       G - dxn square root matrix such that the kernel K = G'*G;
%       bandwidths - nx1 array of pointwise bandwidth (could be computed
%                    using k^{th} nearest neighbor for example
% 
% Output: 
%       labels - nx1 array of labels indicating mode association
%       Z - dxn matrix of converged points after mean shift 


[d, n] = size(G);
pbandwidths = power(bandwidths,d+2);
pbandwidths = repmat(pbandwidths, [1,n]);
nbandwidths = repmat(bandwidths.^2, [1,n]);

on = ones(n,1);
od = ones(d,1);
cn = (G'.*G')*od;

Z = G;
it_max = 10000;

for it = 1:it_max
    cm = (Z'.*Z')*od; % squared distance of each point from origin in d dim space
    D = cm*on' + on*cn' - 2*(Z'*G);
    F = -exp(-.5 * D'./nbandwidths);
    F = F./pbandwidths;
    Y = F./(on*(on'*F));
    Zp = G*Y;
    if (norm(Zp-Z) < 1e-10)
        Z = Zp;
        break;
    end;
    Z = Zp;
end

labels = label_modes(Z'*Z);
return;
end

function labels = label_modes(K)
n = size(K,1);

SM = K;
SSM = repmat(diag(SM),[1,n]);
dist = SSM +SSM' - 2*SM;

labels = zeros(n,1);
modes = [];
modes(1) = 1;
labels(1) = 1;

thd = 1e-9; % distance between two distinct modes

for i=2:n
    d = size(modes,2);
    t=0;
    for j=1:d
        if(dist(i,modes(j)) < thd)
            labels(i) = labels(modes(j));
            t=1;
            break;
        end  
    end
    if(t==0)
        modes(d+1) = i;
        labels(i) = d+1;
    end
end
return;
end