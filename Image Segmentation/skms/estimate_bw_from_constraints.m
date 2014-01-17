function [k,ms_rank] = estimate_bw_from_constraints(K,C)
   
    debug = false;
    npts = size(K,1);
    
    
    [U,S,~] = svd(K);
    s = diag(S);
    cumsum_s = cumsum(s);
    ms_rank = min(find(sqrt(cumsum_s)/sqrt(cumsum_s(end)) > 0.99,1),25);
    s(ms_rank + 1:end) = 0;
    S = diag(s);
    K = U*S*U';
    
    sim_inds = C(:,3) > 0;
    sim_dist_thd = unique(C(sim_inds,4));

    sim_pairs = C(sim_inds,1:2);
   
    unique_sim_pts = unique(sim_pairs(:));
    
    SM = diag(K)*ones(1,npts);
    pdm = SM + SM' - 2*K;
    
    [sorted_pdm,sorted_inds] = sort(pdm,2,'ascend');
    
    sim_pts_pdm = sorted_pdm(unique_sim_pts,:);
    sim_pts_inds = sorted_inds(unique_sim_pts,:);
    
    sim_pts_cell = cell(length(unique_sim_pts),2);
    sim_dist_cell = cell(length(unique_sim_pts),1);
    for i = 1:length(unique_sim_pts),
        this_pt = unique_sim_pts(i);
        inds1 = sim_pairs(sim_pairs(:,1) == this_pt,2);
        inds2 = sim_pairs(sim_pairs(:,2) == this_pt,1);
        sim_pts_cell{i,1} = unique([inds1;inds2])';
        [~,k_vals] = intersect(sim_pts_inds(i,:),sim_pts_cell{i,1});
        k_vals = k_vals(sorted_pdm(this_pt,k_vals) < sim_dist_thd);
        sim_pts_cell{i,2} = k_vals(:)';
        sim_dist_cell{i,1} = sorted_pdm(this_pt,k_vals);
    end

    sim_k_list = nan(npts,1);
    for i = 1:npts,
        sim_k_list(i) = find(sorted_pdm(i,:) > sim_dist_thd,1,'first');
    end
    
    if(debug)
        figure;hist([sim_pts_cell{:,2}],1:100);title('constraint pairs only');
        figure;hist(sim_k_list,1:npts);title('all points');
    end
    k = ceil(median([sim_pts_cell{:,2}]));

    return;
end