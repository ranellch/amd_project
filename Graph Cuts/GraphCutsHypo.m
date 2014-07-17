function [finalLabeling] = GraphCutsHypo(labeling, prob_img, feature_img)
%PREPAREANDCUTONESLICE Summary of this function goes here
%   Detailed explanation goes here
    
    L0Cost = 1 - prob_img;
    L0Cost = -log(L0Cost+eps);
    
    L1Cost = prob_img;
    L1Cost = -log(L1Cost+eps);
    
    hCost = zeros(size(prob_img));
    for i = 1:size(hCost,2)-1
        diff = feature_img(:,i,:) - feature_img(:,i+1,:);
        hCost(:,i) = exp(
    hCost(:,end) = max(hCost(:));
    
    vCost = exp( - diff(im).^2 ./ 2 ./ sigma^2 ) / PS(1);
    vCost = padarray(vCost, [1 0], max(vCost(:)), 'post');
    
    save('.\IM.mat', ...
        'labeling', 'L0Cost', 'L1Cost', 'hCost', 'vCost');
    iterNum = 2;
    call2dCutExecutable;
    load('.\scarSegment\classifyGraphCut\IM.mat', 'optimizedLabeling');
    finalLabeling= optimizedLabeling;

end

