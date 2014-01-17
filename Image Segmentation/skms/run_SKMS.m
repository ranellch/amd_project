%% main script to run SKMS

%% initializations etc.
clear;clc
close all;

global config debug
init_config;

%% SKMS algorithm
% load data 
load(config.data_set_name);
nPts = size(X,1);

sigma_skms = estimate_sigma(X,C);
if(debug.verbose)
    fprintf(1,'Detected sigma: %0.3f\n',sigma_skms);
end
% compute initial kernel
[K0_skms,K0_skms_fr,C,r] = generate_gaussian_kernel(X,sigma_skms,C,nan);
% learn kernel by minimizing log det divergence
[K_skms,slack_vars] = learn_kernel(X,K0_skms,C,r);
% estimate bandwidth parameter
[k,ms_rank] = estimate_bw_from_constraints(K_skms,C);
% perform mean shift clustering
[labels_skms,~,~,mode_gammas] = kernel_mean_shift_clustering(K_skms,k,ms_rank);

%% evaluation of clustering performance using ground truth
[CA_skms,RI_skms,AR_skms] = compute_clustering_performance(gt_data,labels_skms);
label_ids = unique(labels_skms)';
nClusters = length(label_ids);

fprintf(1,'\nSKMS clustering performance:\n AR = %.2f, CA = %.2f and RI = %.2f\n',...
    AR_skms,CA_skms,RI_skms);
%% display results

if(debug.vis_results)
    leg_str = num2str(ms_rank);
    
    SM = mode_gammas'*K_skms*mode_gammas;
    SSM = repmat(diag(SM),[1,nPts]);
    pdm_modes = SSM + SSM' - 2*SM;
    fig_h_skms = figure;
    
    
    % specify some colors for plotting
    colors = rand(nClusters,3);
    colors(1,:) = [1 0 0];
    colors(2,:) = [0 1 0];
    colors(3,:) = [0 0 1];
    colors(4,:) = [0 1 1];
    colors(5,:) = [0 0 0];
    
    % plot clustered data in input space
    subplot(1,2,1); hold on;
    for label_i = label_ids 
        plot(X(labels_skms == label_i,1), X(labels_skms == label_i,2),'.',...
            'color',colors(label_ids == label_i,:));
    end
    axis equal;
    title('Clustering Output');
    % plot pairwise distance matrix (pdm) of modes as image
    subplot(1,2,2);
    imshow(pdm_modes,[]);%impixelinfo;
    title('Pairwise Distance Matrix');
    
end