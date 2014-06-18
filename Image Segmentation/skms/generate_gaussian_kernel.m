function [K0_kmsml,K0_fr,C,r] = generate_gaussian_kernel(X,sigma,C,r)
    global config
    if(nargin < 4 )
        r = nan;
    end

    [K0_fr] = fast_gram_matrix(X',sigma); % full rank initial kernel matrix
    [U,S,V] = svd(K0_fr);
    s0_fr = diag(S);
    
    if(config.useLowRank)
        if(isnan(r))
            r = find(sqrt(cumsum(s0_fr))/sqrt(sum(s0_fr)) >= 0.99,1);
        end
    else
        r = inf;
    end
    r = min(size(K0_fr,2),r);
    
    U = U(:,1:r);
    S = S(1:r,1:r);
    V = V(:,1:r);
    K0_kmsml = U*S*V';
    if(isempty(C))
        return;
    end

    % adjust constraint distance thresholds
    SM0 = diag(K0_kmsml)*ones(1,size(K0_kmsml,2));
    pdm0 = SM0 + SM0' - 2*K0_kmsml;
    
    [temp_n,temp_x] = hist(pdm0(:),200);
    
    temp_n = cumsum(temp_n)/sum(temp_n);
    l_ind = find(temp_n>=0.05,1,'first');
    l_K0 = temp_x(l_ind);
    u_ind = find(temp_n>=0.95,1,'first');
    u_K0 = temp_x(u_ind);
    sim_inds_C = C(:,3)>0;
    C(sim_inds_C,4) = min(0.1,l_K0);
    C(~sim_inds_C,4) = max(1.9,u_K0);

return;
end



function [K,dist_mat] = fast_gram_matrix(data, sigma)

% Fast gram matrix computation for gaussian kernel
[n m] = size(data);
K = zeros(m,m);
if(n < m)
    for i=1:n
        T = repmat(data(i,:), m,1);
        T = T - T';
        K = K + T.*T;
    end
    dist_mat = K;
    K = -K./(2*sigma*sigma);
    K = exp(K);
else
    for i = 1:m,
        for j = i:m,
            temp = (data(:,i)-data(:,j));
            K(i,j) = exp(- (temp'*temp)/(2*sigma*sigma));
            K(j,i) = K(i,j);
        end
    end
end

return;
end