function [cleanLabeling] = vesselCCFilterRemoveRoundBlobs(vesselmask, prct)
% [cleanLabeling] = vesselCCFilterRemoveSmallBlobs(vesselmask, N)
%   connected component number analysis

vesselmask = bwmorph(vesselmask, 'fill');

CC = bwconncomp(vesselmask, 4);
STATS = regionprops(CC, 'basic');
roundflags = false(length(STATS), 1);
ub = 1+prct;
lb = 1-prct;
for i = 1:length(STATS)
    x = STATS(i).BoundingBox(3);
    y = STATS(i).BoundingBox(4);
    r = (x+y)/4;
    theory_area = pi*r^2;
    
    if x/y>lb && x/y<ub && theory_area/STATS(i).Area<ub && ...
            theory_area/STATS(i).Area>lb
        roundflags(i) = 1;
    end
end

% keep only the N largest components
idx = find(roundflags);
cleanLabeling = vesselmask;
for i = 1:length(idx)
    cleanLabeling(CC.PixelIdxList{idx(i)}) = 0;
end

end

