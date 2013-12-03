function [imgout] = apply_kmeans(imgvec)
    final_matrix = zeros(size(imgvec,1) * size(imgvec, 2), size(imgvec, 3));
    final_matrix_mapping = zeros(size(imgvec,1) * size(imgvec, 2), 2);
    final_index = 0;
    
    for y=1:size(imgvec, 1)
        for x=1:size(imgvec, 2)
            final_index = final_index + 1;
            final_matrix(final_index,:) = imgvec(y,x,:);
            final_matrix_mapping(final_index, :) = [y, x];
        end
    end
    
    %Apply the kmeans to it
    number_of_clusters = 8;
    maxiter = statset('MaxIter', 500);
    [idx, ~] = kmeans(final_matrix, number_of_clusters, 'EmptyAction', 'singleton', 'options', maxiter);
    
    %Try to build the kmeans imaging vectors
    imgout = zeros(size(imgvec, 1), size(imgvec, 2));
    for index=1:size(idx, 1)
        imgout(final_matrix_mapping(index, 1), final_matrix_mapping(index, 2)) = (idx(index) / number_of_clusters);
    end
    
    %Show the map 
    figure, imshow(imgout);
    colormap(jet);
end