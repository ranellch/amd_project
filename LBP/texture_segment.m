function [ Iseg ] = texture_segment( I )
%returns segmented image with uniform texture regions
%fun must be a handle

mindim = 16;
maxdim = 128;


%Perform hierarchal splitting
S = qtdecomp(I, @split_test, @splitpred_texture);






%------------------------------------------------------------------------
function v = split_test(B, splitpred)
    %Determines whether quadregions are split.  Returns in v logical 1s for
    %the blocks that should be split and logical 0s for those that should
    %not.
    
    k = size(B,3); %number of regions in B at this step
    
    v(1:k) = false;
    for i = 1:k
        quadregion = B(:,:,i);
        length = size(quadregion,1); % size of B
        if length > maxdim
            v(i) = true;
            continue
        end
        if length <= mindim || any(quadregion(:)) == false;
            v(i) = false;
            continue
        end
        % get quadtree decomp of current block, check predicate
        % function for similarity of adjacent sub-blocks
        newlength = length/2;
        index = 1;
        blk_regions = zeros(newlength, newlength, 4);
        for m = 1:2
            for n = 1:2
                blk_regions(:,:, index) = quadregion(1+(m-1)*newlength:m*newlength, ...
                    1+(n-1)*newlength:n*newlength);
                index=index+1;
            end
        end
        flag = feval(splitpred, blk_regions);
        if ~flag 
            v(i) = true;
        end
    end   
end


%-------------------------------------------------------------------------
function [ flag ] = splitpred_texture(blk_regions)
%SPLITPRED_TEXTURE Contains the predicate used to determine whether to split
%or merge regions during the hierarchal splitting phase of texture based segmentation.

for i = 1:4
    SP=[-1 -1; -1 0; -1 1; 0 -1; -0 1; 1 -1; 1 0; 1 1];
    h(i)=lbp_c(blk_regions(i),SP,0,'h');
end
 
for i = 1:6
    f = numel(h(i));
    G(i) = 2* sum((f).*log(f))
  

end

end

