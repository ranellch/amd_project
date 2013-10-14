function [ MI ] = texture_segment( I )
%returns segmented image with uniform texture regions
%fun must be a handle

global  mindim maxdim

mindim = 16;
maxdim = 128;

dims = [128 64 32 16]; 

%Smooth noise
H = fspecial('gaussian',[5 5], 1.5);
I=imfilter(I,H);

%Pad image with zeros to guarantee that function qtdecomp will split
%regions down to sizes  divisible by 2.
Q = 2^nextpow2(max(size(I)));
[M, N] = size(I);
I = padarray(I, [Q-M, Q-N], 'post');


%***Perform hierarchal splitting
S = qtdecomp(I, @split_test, @splitpred_texture);
numdims = length(dims);
Ihier = 255*ones(M,N);
regions = cell(nnz(full(S)),3);
%store merged regions in cell array, cols: 1=histogram, 2=included quadtree region
%corners, 3=square dimensions for each corner
idx=1;
for z = 1:numdims;  
    dim = dims(z);
    [vals, r, c] = qtgetblk(I, S, dim);
    for j = 1:length(r)
        hist = lbp_c(vals(:,:,j));
        regions{idx,1} = hist+hist==0;
        regions{idx,2} = [r(j),c(j)];
        regions{idx,3} = dim;
        idx=idx+1;
        Ihier(r(j)+2:r(j)+dim-2,c(j)+2:c(j)+dim-2) = vals(2:end-2,2:end-2,j);
    end
end

Ihier = Ihier(1:M,1:N); %crop out padding
figure, imshow(Ihier,[])

%***Perform Agglomerative Merging
strt_regions = size(regions,1);
MI = zeros(1000,1);
count = 1;
keep_merging = true;
while keep_merging
    numregions = size(regions,1);
    for j = 1:numregions
        hist1 = regions{j,1};
        corners1 = regions{j,2};
        extents1 = regions{j,3};
        MImin = 1e20;
        for k = 1:numregions
            if k==j
                continue
            end
            corners2 = regions{k,2};
            extents2 = regions{k,3};
            %check if above region1
             if any(corners2(:,1)+extents2 == corners1(:,1)-1 & ...
                    (corners1(:,2) <= (corners2(:,2)+extents2) & corners1(:,2) >= corners2(:,2)))
                hist2 = regions{k,1};
                p = min([sum(extents1.^2), sum(extents2.^2)]);
                MI = p*G_statistic(hist1,hist2);
                if MI < MImin                    
                   MImin = MI;
                   merge_idx = k;
                end
                continue
             end                
            %check if below region1
            if any(corners2(:,1) == corners1(:,1)+extents1+1 & ...
                    (corners1(:,2) <= (corners2(:,2)+extents2) & corners1(:,2) >= corners2(:,2)))
                hist2 = regions{k,1};
                p = min([sum(extents1.^2), sum(extents2.^2)]);
                MI = p*G_statistic(hist1,hist2);
                if MI < MImin                   
                   MImin = MI;
                   merge_idx = k;
                end
                continue
            end
            %check if to the left of region1
             if any(corners2(:,2)+extents2 == corners1(:,2)-1 & ...
                    (corners1(:,1) <= (corners2(:,1)+extents2) & corners1(:,1) >= corners2(:,1)))
                hist2 = regions{k,1};
                p = min([sum(extents1.^2), sum(extents2.^2)]);
                MI = p*G_statistic(hist1,hist2);
                if MI < MImin                    
                   MImin = MI;
                   merge_idx = k;
                end
                continue
            end
            %check if to the right of region1
             if any(corners2(:,1) == corners1(:,2)+extents1+1 & ...
                    (corners1(:,1) <= (corners2(:,1)+extents2) & corners1(:,1) >= corners2(:,1)))
                hist2 = regions{k,1};
                p = min([sum(extents1.^2), sum(extents2.^2)]);
                MI = p*G_statistic(hist1,hist2);
                if MI < MImin                
                   MImin = MI;
                   merge_idx = k;
                end
                continue
             end                        
        end
        %merge region with smallest merger importance (MI) provided stopping rule is not
        %invoked
        MIR = MImin/max(MI);
        if MIR > 2.0 && count > round(.1*(strt_regions/2))
            keep_merging = false;
        else
            regions{j,1} = hist1+regions{merge_idx,1};
            regions{j,2} = [regions{j,2}; regions{merge_idx,2}];
            regions{j,3} = [regions{j,3}; regions{merge_idx,3}];
            regions{merge_idx,1} = [];
            regions{merge_idx,2} = [];
            regions{merge_idx,3} = [];
            regions = regions(~cellfun('isempty',regions)); 
            MI(count) = MImin;
            count = count+1;
            keep_merging = true;
        end
    end
end


%***Perform Pixelwise Classification
 

end

%------------------------------------------------------------------------
function v = split_test(B, splitpred)
    %Determines whether quadregions are split.  Returns in v logical 1s for
    %the blocks that should be split and logical 0s for those that should
    %not.
    global maxdim mindim
    k = size(B,3); %number of regions in B at this step
    
    v(1:k) = false;
    for i = 1:k
        quadregion = B(:,:,i);
        s = size(quadregion,1); % size of B
        if s > maxdim
            v(i) = true;
            continue
        end
        if s <= mindim || any(quadregion(:)) == false;
            v(i) = false;
            continue
        end
        % get quadtree decomp of current block, check predicate
        % function for similarity of adjacent sub-blocks
        newlength = s/2;
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
        if flag 
            v(i) = true;
        end
    end   
end



%-------------------------------------------------------------------------
function [ flag ] = splitpred_texture(blk_regions)
%SPLITPRED_TEXTURE Contains the predicate used to determine whether to split
%or merge regions during the hierarchal splitting phase of texture based segmentation.

hists=zeros(256,8,4);

for i = 1:4
    hists(:,:,i) =lbp_c(blk_regions(:,:,i));
end

index = 1;
G=zeros(6,1);
for m = 1:3
    hist1 = hists(:,:,m);
    hist1(hist1==0) = 1;
    for n = m+1:4 
        hist2 = hists(:,:,n);
        hist2(hist2==0) = 1;        
        G(index) = G_statistic(hist1,hist2);       
    index=index+1;   
    end
end

R=max(G)/min(G);

if R > 1.08
    flag = true;
else 
    flag = false;
end

end

