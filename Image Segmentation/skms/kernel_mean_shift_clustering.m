function [labels,bandwidths,lrK,mode_gammas,fig_h] = kernel_mean_shift_clustering(K,nn,ms_rank)


global debug 

fig_h = [];

if(nargin < 5)
   cond_no = inf; 
end
n = size(K,1); 

[Uk,Sk] = svd(K);
r = rank(K);

eff_r = min(r,ms_rank);

if(debug.verbose)
    fprintf(1,'\n rank of kernel = %d, effective rank of kernel = %d and ''k'' = %d\n',r,eff_r,nn);
end
r = eff_r; 

Sk = Sk(1:r,1:r);
Uk = Uk(:,1:r);
lrK = sqrt(Sk)*Uk';

bandwidths = fast_get_bandwidths(lrK'*lrK,nn);
bandwidths(bandwidths<1e-9) = 1e-8;
bandwidths = bandwidths';
[mode_gammas, ~, labels1] = kms_clustering_vb(lrK,sqrt(bandwidths));


SM = mode_gammas'*K*mode_gammas;
SSM = repmat(diag(SM),[1,n]);
pdm = SSM +SSM' - 2*SM;

labels = merge_plot_modes(pdm, 1e-9);

 if(debug.verbose)
    fprintf('\n Running Kernel mean-shift on %d dimensional data\n',size(lrK,1));
    fprintf('\n Mean Shift discovered %d clusters\n',length(unique(labels)));
end

assert(all((labels-labels1)==0));
return;

end

function bandwidths = fast_get_bandwidths(K, nn)

[n] = size(K,1);
bandwidths = zeros(1,n);

d = zeros(n,n);
ss = repmat(diag(K), [1,n]);
d = ss + ss' - 2*K;
for i=1:n
    v = sort(d(i,:));
    bandwidths(i) = v(nn);
end
return;
end

function [labels] = merge_plot_modes(dist, th)

n = size(dist,1);

labels = zeros(n,1);
modes = [];
modes(1) = 1;
labels(1) = 1;

for i=2:n
    d = size(modes,2);
    t=0;
    for j=1:d
        if(dist(i,modes(j)) < th)
            labels(i) = labels(modes(j));
            t=1;
            break;
        end;            
    end;
    
    if(t==0)
        modes(d+1) = i;
        labels(i) = d+1;
    end
end
return;
end