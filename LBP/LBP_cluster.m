function [ Iseg, data ] = LBP_cluster( I, dim, r, k )
%LBP_CLUSTER(I, dim, k) Breaks I up into (dim) by (dim) pixel blocks and obtains 256 bin LBP histograms with patterns defined on radius r.  
%(k) clusters are determined using k-Means and recolored image Iseg is
%provided as output along with binary images of clusters and their centers
%(feature vectors) in data.cluster and data.center respectively

figure, imshow(I);

%Mirror pad I so it is divisible by dim 
[M, N] = size(I);
Q1 = ceil(M/dim)*dim;
Q2 = ceil(N/dim)*dim;
I = padarray(I, [Q1-M, Q2-N], 'symmetric', 'post');

%run LBP on dim x dim blocks
sizeI = size(I);
Hist_rows = sizeI(1)/dim;
Hist_cols = sizeI(2)/dim;
numHists= Hist_rows*Hist_cols;
allHists =zeros(numHists,256);
for i= 1:Hist_rows
    for j= 1:Hist_cols
        index= (i-1)*Hist_cols+j;
        block= I((i-1)*dim+1:i*dim,(j-1)*dim+1:j*dim);
        hist=lbp(block,r,8,0,'nh');
        allHists(index,:)=hist;
    end
end
Iseg = I;
[idx, c]= kmeans(allHists,k,'EmptyAction','singleton');
for i = 1:Hist_rows
    for j = 1:Hist_cols
        index = (i-1)*Hist_cols+j;
        Iseg((i-1)*dim+1:i*dim,(j-1)*dim+1:j*dim) = idx(index); 
    end
end


Iseg = Iseg(1:M,1:N);
data = struct('cluster',cell(k,1),'center',cell(k,1));

for i = 1:k
    data(i).cluster=Iseg==i;
    data(i).center=c(i,:);
end

Iseg=double(Iseg)./k; %get colors
figure, imshow(Iseg)
colormap(jet)


end
