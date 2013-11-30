function cluster_many( paths, dim, k )
%k-means cluster textures over a bunch of images using SFTA with k clusters

num_images = size(paths,1);
totalVecs = [];
Q1=zeros(1,num_images);
Q2=zeros(1,num_images);
M=zeros(1,num_images);
N=zeros(1,num_images);
vector_rows=zeros(1,num_images);
vector_cols=zeros(1,num_images);

for p = 1:num_images

    I=rgb2gray(imread(paths{p,:}));

    %Mirror pad I so it is divisible by dim 
    [M(p), N(p)] = size(I);
    Q1(p) = ceil(M(p)/dim)*dim;
    Q2(p) = ceil(N(p)/dim)*dim;
    I = padarray(I, [Q1(p)-M(p), Q2(p)-N(p)], 'symmetric', 'post');

    %run SFTA on dim x dim blocks
    nt = 3;
    sizeI = size(I);
    vector_rows(p) = sizeI(1)/dim;
    vector_cols(p) = sizeI(2)/dim;
    numVecs= vector_rows(p)*vector_cols(p);
    allVecs =zeros(numVecs,6*nt);
    for i= 1:vector_rows(p)
        for j= 1:vector_cols(p)
            index= (i-1)*vector_cols(p)+j;
            block= I((i-1)*dim+1:i*dim,(j-1)*dim+1:j*dim);
            vec=sfta(block,nt);
            allVecs(index,:)=vec;
        end
    end
    totalVecs = [totalVecs; allVecs];
end

[idx, c] = kmeans(totalVecs,k,'EmptyAction','singleton');

for p = 1:num_images
    Iseg = zeros(Q1(p),Q2(p));
    for i = 1:vector_rows(p)
        for j = 1:vector_cols(p)
            if p ~= 1
                index = vector_rows(p-1)*vector_cols(p-1)+(i-1)*vector_cols(p)+j;
            else
                index = (i-1)*vector_cols(p)+j;
            end
            Iseg((i-1)*dim+1:i*dim,(j-1)*dim+1:j*dim) = idx(index); 
        end
    end

    Iseg = Iseg(1:M(p),1:N(p));
    Iseg=double(Iseg)./k; %get colors
    figure, imshow(Iseg)
    colormap(jet)
end
end

