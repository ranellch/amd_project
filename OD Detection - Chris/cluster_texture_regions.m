function [final_clusters, final_clusters_mask] = cluster_texture_regions(img)
    %Clean up the really small regions
    cleaned = imfill(img, 'holes');
    cleaned = bwareaopen(cleaned, 20);
    conn_regions = bwconncomp(cleaned);
    max_num_regions = conn_regions.NumObjects;
    
    %Get the total number of datapoints to cluster
    total_size = 0;
    for y=1:size(cleaned, 1)
        for x=1:size(cleaned,2)
            if(cleaned(y,x) == 1)
                total_size = total_size + 1;
            end
        end
    end
    
    %Reformat the input dataset to push into the clusterdata function
    output_list = zeros(total_size, 2);
    current_index = 1;
    for y=1:size(cleaned, 1)
        for x=1:size(cleaned,2)
            if(cleaned(y,x) == 1)
                output_list(current_index, 1) = x;
                output_list(current_index, 2) = y;
                current_index = current_index + 1;
            end
        end
    end

    %Cluster the output data
    cutoffval = round(max_num_regions / 2);
    if(cutoffval <= 2)
        cutoffval = 4;
        disp('Resized the cutoff val');
    end

    out = clusterdata(output_list, 'cutoff', cutoffval, 'distance', 'euclidean', 'criterion', 'distance');
    cluster_count = histc(out, unique(out));

    disp(cluster_count);
    
    %Remap the clustered output to a results image
    final_clusters = zeros(size(img,1), size(img,2));
    current_index = 1;
    for y=1:size(cleaned, 1)
        for x=1:size(cleaned,2)
            if(cleaned(y,x) == 1)
                final_clusters(y,x) = out(current_index);
                current_index = current_index + 1;
            end
        end
    end
        
    
    final_clusters_mask = zeros(size(final_clusters, 1), size(final_clusters, 2));
        
    %Estimate an ellipses function and then draw it
    for i=1:numel(cluster_count)
        %Ignore this cluster if it is really tiny
        if(cluster_count(i) < 30)
            continue;
        end

        xs = output_list(out(:) == i, 1);
        ys = output_list(out(:) == i, 2);
        
        Mu = mean(horzcat(xs, ys));
        X0 = bsxfun(@minus, horzcat(xs, ys), Mu);
        
        %Get an ellipse that covers 2 standard deviations of all datapoints
        STD = 2;                     %# 2 standard deviations
        conf = 2*normcdf(STD)-1;     %# covers around 95% of population
        scale = chi2inv(conf,2);
        
        Cov = cov(X0) * scale;
        [V, D] = eig(Cov);
        
        [D, order] = sort(diag(D), 'descend');
        D = diag(D);
        V = V(:, order);
        
        t = linspace(0,2*pi,100);
        e = [cos(t) ; sin(t)];        %# unit circle
        VV = V*sqrt(D);               %# scale eigenvectors
        e = bsxfun(@plus, VV*e, Mu'); %#' project circle back to orig space
        
        %Create a ROI mask from datapoints create from ellipses estimation
        ellipse_mask = roipoly(final_clusters, e(1,:), e(2,:));
        
        %Trasnpose this mask onto another image
        for y=1:size(ellipse_mask, 1)
            for x=1:size(ellipse_mask, 2)
                if(ellipse_mask(y,x) == 1)
                    final_clusters_mask(y,x) = i;
                end
            end
        end
    end
    
    %figure(1), imagesc(final_clusters);
    %figure(2), imagesc(final_clusters_mask);
end