function [log_det_div,log_det_K0,sqrd_dist,p] = compute_log_det_xi(K0,C)


% initializations 
nConstraints = size(C,1);
npts = size(K0,1);
log_det_K0 = 0;


sim_inds = C(:,3) > 0;
dis_inds = C(:,3) < 0;
xi_0 = C(:,4);
if(any(xi_0 == 0))
    error('constraint distance can not be zero');
end
xi_ratio = nan(size(xi_0));
p = nan(size(xi_0));

for const_i = 1:nConstraints,
    i1 = C(const_i,1);
    i2 = C(const_i,2);
    e_i1 = zeros(npts,1);
    e_i2 = zeros(npts,1);
    e_i1(i1) = 1;
    e_i2(i2) = 1;
    v_i12 = e_i1 - e_i2;
    
    this_xi = xi_0(const_i);
    
    if(C(const_i,3) > 0)
        p(const_i) = max(this_xi,K0(i1,i1) + K0(i2,i2) - 2*K0(i1,i2));
    else
        p(const_i) = min(this_xi,K0(i1,i1) + K0(i2,i2) - 2*K0(i1,i2));
    end
    
    xi_ratio(const_i) = xi_0(const_i)/p(const_i);
end
sqrd_dist = norm(xi_0 - p);
log_det_div(1) = sum(xi_ratio - log(xi_ratio) - 1); 
log_det_div(2) = sum(xi_ratio(sim_inds) - log(xi_ratio(sim_inds)) - 1);
log_det_div(3) = sum(xi_ratio(dis_inds) - log(xi_ratio(dis_inds)) - 1);


return;
end
