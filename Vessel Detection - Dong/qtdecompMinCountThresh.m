function [qt_sparse, dims] = qtdecompMinCountThresh(vesselmap, thresh, disp_opt, vesseloverlayimg)

% quad-tree decomposition with a threshold of a minimum number of masked
% pixels in each block

function [decisions] = splitDecision(blockStacks)
%SPLITDECISION Summary of this function goes here
%   Detailed explanation goes here
    decisions = false(size(blockStacks,3), 1);
    m = size(blockStacks, 2);
    for k = 1:size(blockStacks, 3)
        count1 = sum(sum(blockStacks(1:m/2,1:m/2,k)));
        count2 = sum(sum(blockStacks(m/2+1:m,1:m/2,k)));
        count3 = sum(sum(blockStacks(1:m/2,m/2+1:m,k)));
        count4 = sum(sum(blockStacks(m/2+1:m,m/2+1:m,k)));
        if count1>=thresh && count2>=thresh && count3>=thresh && count4>=thresh
            decisions(k) = true;
        end
    end
end

qt_sparse = qtdecomp(vesselmap, @splitDecision);
dims_n_zero = unique(qt_sparse);
dims = full(dims_n_zero(dims_n_zero~=0)).';

if exist('disp_opt', 'var') && disp_opt
    blocks = repmat(uint8(0),size(qt_sparse));
    
    for dim = dims
        numblocks = length(find(qt_sparse==dim));
        values = repmat(uint8(1),[dim dim numblocks]);
        values(2:dim,2:dim,:) = 0;
        blocks = qtsetblk(blocks,qt_sparse,dim,values);
    end
    
    blocks(end,1:end) = 1;
    blocks(1:end,end) = 1;
    
    figure; imshowpair(vesseloverlayimg, blocks, 'blend');
end

end

