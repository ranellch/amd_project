function [ flag ] = splitpred_texture(blk_regions)
%SPLITPRED_LEAK Contains the predicate used to determine whether to split
%or merge regions during the hierarchal splitting phase of texture based segmentation.

for i = 1:4
    SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    h(i)=lbp(blk_regions(i),SP,0,'h');
end
 
for i = 1:6
    f = numel(h(i));
    G(i) = 2* sum((f).*log(f))
  

end

