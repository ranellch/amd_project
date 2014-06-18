function [cleanLabeling] = vesselCCFilterKeepLargestN(vesselmask, N)
% [cleanLabeling] = vesselCCFilterKeepLargestN(vesselmask, N)
%   connected component number analysis

CC = bwconncomp(vesselmask);
numPixels = cellfun(@numel, CC.PixelIdxList);

% keep only the N largest components
[~, idx] = sort(numPixels, 'descend');
cleanLabeling = false(size(vesselmask));
cleanLabeling(CC.PixelIdxList{idx(1)}) = 1;
if numel(idx) <= N
    cleanLabeling = vesselmask;
else
    for i = 1:N
        cleanLabeling(CC.PixelIdxList{idx(i)}) = 1;
    end
end

end

