function [det_sigma] = estimate_sigma(X,C,sigma_list)
% USAGE: det_sigma = estimate_sigma(X,C,sigma_list)
% Input: 
%       X - nPts x dim data matrix
%       C - nConstraints x 4 constraint matrix
%       sigma_list - list of sigma values to chose from
%                    can also be specified in config (See init_config.m)
% Output: 
%       det_sigma - selected sigma value from sigma_list


global config debug

if(~isstruct(debug))
    debug.est_sigma = false;
end

if(nargin < 3)
sigma_list = config.sigma_list;
end

nsig = length(sigma_list);
full_log_det_K0 = zeros(1,nsig);
full_log_det = zeros(1,nsig);
sim_log_det = zeros(1,nsig);
dis_log_det = zeros(1,nsig);
for sigma_i = 1:nsig,
    this_sigma = sigma_list(sigma_i);
    [~,K0_kmsml] = generate_gaussian_kernel(X,this_sigma,[],inf);

    [log_det_div,log_det_div_K0] = compute_log_det_xi(K0_kmsml,C);
    full_log_det_K0(sigma_i) = log_det_div_K0;
    full_log_det(sigma_i) = log_det_div(1);
    sim_log_det(sigma_i) = log_det_div(2); 
    dis_log_det(sigma_i) = log_det_div(3);

       
    
end

[~,det_ind] = min(full_log_det,[],2);
det_sigma = sigma_list(det_ind);

if(debug.estimate_sigma)
    dist_thd = unique(C(:,4))';
    h = figure;plot(sigma_list,full_log_det,'o-');grid on;
    title(['D_l_d(\xi_0,p_K_0); \sigma = ',num2str(det_sigma(1))]);
    xlabel('\sigma -------->');ylabel('D_l_d(\xi_0,p_K_0) --------->');
    set(h,'name',config.data_set_name);
end


return;
end