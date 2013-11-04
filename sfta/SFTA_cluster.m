function [ Iseg ] = SFTA_cluster( I, dim, k )
% SFTA_CLUSTER(I, dim, k) Breaks I up into (dim) by (dim) pixel blocks and obtains SFTA (nt=3) feature vectors.  
%(k) clusters are determined using k-Means and recolored image Iseg is provided as output

figure, imshow(I);

%Mirror pad I so it is divisible by dim 
[M, N] = size(I);
Q1 = ceil(M/dim)*dim;
Q2 = ceil(N/dim)*dim;
I = padarray(I, [Q1-M, Q2-N], 'symmetric', 'post');

%run SFTA on dim x dim blocks
nt = 3;
sizeI = size(I);
Hist_rows = sizeI(1)/dim;
Hist_cols = sizeI(2)/dim;
numHists= Hist_rows*Hist_cols;
allHists =zeros(numHists,6*nt);
for i= 1:Hist_rows
    for j= 1:Hist_cols
        index= (i-1)*Hist_cols+j;
        block= I((i-1)*dim+1:i*dim,(j-1)*dim+1:j*dim);
        hist=sfta(block,nt);
        allHists(index,:)=hist;
    end
end
Iseg = I;
idx = kmeans(allHists,k,'EmptyAction','singleton');
for i = 1:Hist_rows
    for j = 1:Hist_cols
        index = (i-1)*Hist_cols+j;
        Iseg((i-1)*dim+1:i*dim,(j-1)*dim+1:j*dim) = idx(index); 
    end
end

Iseg = Iseg(1:M,1:N);
Iseg=double(Iseg)./k; %get colors
figure, imshow(Iseg)
colormap(jet)

end
