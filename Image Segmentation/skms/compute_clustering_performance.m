function [CA,RI,AR,conf_mat] = compute_clustering_performance(gt_data,labels)

true_labels = unique(gt_data);
true_labels = true_labels(:)';
temp_gt_data = nan(size(gt_data));
cnt = 0;
for gt_i = true_labels;
    cnt = cnt + 1;
    inds = gt_data == gt_i;
    temp_gt_data(inds) = cnt;
end
gt_data = temp_gt_data;
true_labels = 1:length(true_labels);

nPoints = nan(length(true_labels),1);

for i = 1:length(true_labels),
    nPoints(i) = sum(gt_data == true_labels(i));
end


if(any(true_labels == 0))
    gt_data = gt_data + 1;
end


%Rand Index
[AR,RI]=RandIndex(gt_data,labels);

% Clustering Accuracy or Purity
conf_mat = Contingency(gt_data,labels);
if(size(conf_mat,1) ~= size(conf_mat,2))
    conf_mat_temp = zeros(max(size(conf_mat)));
    conf_mat_temp(1:size(conf_mat,1),1:size(conf_mat,2)) = conf_mat;
    conf_mat = conf_mat_temp;
end
cost_mat = - conf_mat; % nPoints*ones(1,length(found_clusters)) 

[Cluster_assmt]=hungarian(cost_mat);

CA = [];
for i = 1:length(Cluster_assmt),
    CA = [CA conf_mat(Cluster_assmt(i),i)];
end
CA = fliplr(sort(CA));
CA = sum(CA(1:length(true_labels)));
CA = CA/sum(conf_mat(:));

end