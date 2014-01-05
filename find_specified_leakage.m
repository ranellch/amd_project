function [sizes,centroids] = find_specified_leakage( path )
%FIND_SPECIFIED_LEAKAGE determines centroids and size of colored outlined regions as percentages of total pixels in I 
%use stats.Area and stats.Centroid to access data

I=imread(path);
I=I(:,round(size(I,2)/2):size(I,2),:);
outline_map = I(:,:,1) > (I(:,:,2)+20);
blobs = imfill(outline_map,'holes');

% figure, imshow(blobs)

stats = regionprops(blobs,'Area', 'Centroid');
sizes=zeros(length(stats),1);
centroids = zeros(length(stats),2);

for i=1:length(stats)
    sizes(i) = stats(i).Area/(size(I,1)*size(I,2))*100;
    centroids(i,:) = stats(i).Centroid;
end

