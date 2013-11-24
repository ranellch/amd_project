function [  ] = texture_segment( I )
%returns segmented image with uniform texture regions

global  mindim maxdim

mindim = 16;
maxdim = 128;

dims = [128 64 32 16]; 

%Smooth noise
% H = fspecial('gaussian',[5 5], 1.5);
% I=imfilter(I,H);

%Pad image with zeros to guarantee that function qtdecomp will split
%regions down to sizes divisible by 16.
Q = 2^nextpow2(max(size(I))/16)*16;
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
        hist = lbp(vals(:,:,j),4,8, 0, 'nh');
        regions{idx,1} = hist;
        regions{idx,2} = [r(j),c(j)];
        regions{idx,3} = dim;
        idx=idx+1;
        Ihier(r(j)+2:r(j)+dim-2,c(j)+2:c(j)+dim-2) = vals(2:end-2,2:end-2,j);
    end
end

Ihier = Ihier(1:M,1:N); %crop out padding
figure, imshow(Ihier,[])
colormap(gray)

%***Perform Agglomerative Merging
strt_regions = size(regions,1);
MI_all = zeros(1000,1);
MIR_all = [];
count = 1;
keep_merging = true;
numregions = strt_regions;
while keep_merging && numregions > 1
    for j = 1:numregions
        if keep_merging==false 
            break
        end
        if isempty(regions{j,1})
            continue
        end
        hist1 = regions{j,1};
        extents1 = regions{j,3};
        MImin = 0;
        start = true;
        for k = 1:numregions
            if k==j || isempty(regions{k,1})
                continue
            end
            extents2 = regions{k,3};
            hist2 = regions{k,1};
            p = min([sum(extents1.^2), sum(extents2.^2)]);
            MI = p*G_statistic(hist1,hist2);
            if MI < MImin || start==true                  
               MImin = MI;
               merge_idx = k;
            end
            start=false;
         end                
        %merge region with smallest merger importance (MI) provided stopping rule is not
        %invoked
        MIR = abs(MImin/max(MI_all));
        if MIR > 2 && count > round(.1*(strt_regions-1))
            keep_merging = false;
        else
            regions{j,1} = hist1+regions{merge_idx,1};
            regions{j,1} = regions{j,1}./repmat(sum(sum(regions{j,1})),1,256); %normalize
            regions{j,2} = [regions{j,2}; regions{merge_idx,2}];
            regions{j,3} = [regions{j,3}; regions{merge_idx,3}];
            regions{merge_idx,1} = []; %mark for deletion
            MI_all(count) = MImin;
            MIR_all(count) = MIR;
            count = count+1;
            keep_merging = true;
        end
    end
    regions(any(cellfun('isempty',regions),2),:)=[];
    numregions = size(regions,1);
end

%Get border pixels, set to different colors
cmap = colormap(jet);
Iout = cat(3,I,I,I);
 for i = 1:numregions
     binmask = zeros(size(I));
     allcorners = regions{i,2};
     alldims = regions{i,3};
     for j = 1:length(alldims)
         corner_x = allcorners(j,2);
         corner_y = allcorners(j,1);
         dim = alldims(j);
         binmask(corner_y:corner_y+dim-1, corner_x:corner_x+dim-1) = 1;
     end
     binmask = logical(binmask);
     bordermask = bwperim(binmask);
     for j = 1:3
        bordermask(bordermask) = cmap(i,j);
        Iout(:,:,j) = bordermask;
     end
 end

Iout = Iout(1:M,1:N,:);
 figure, imshow(Iout);
 colormap(jet)
 
 figure, plot(MIR_all)
    
     

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

hists=zeros(256,4);

for i = 1:4
    hists(:,i) =lbp(blk_regions(:,:,i),4,8,0,'nh');
end

index = 1;
G=zeros(6,1);
for m = 1:3
    hist1 = hists(:,m);
    for n = m+1:4 
        hist2 = hists(:, n);
        hist2(hist2==0) = 1;        
        G(index) = G_statistic(hist1,hist2);       
    index=index+1;   
    end
end

R=max(G)/min(G);

if R > 1.05
    flag = true;
else 
    flag = false;
end

end

