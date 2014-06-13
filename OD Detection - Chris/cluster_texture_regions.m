function [final_clusters, final_clusters_mask] = cluster_texture_regions(img, varargin)
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
    end

    %Clean up the really small regions and holes in mostly clustered areas
    cleaned = imfill(img, 'holes');
    cleaned = bwareaopen(cleaned, 9);
    
    %Downsample if necessary to maxsamples
    total_samples = sum(cleaned(:) == 1);
    maxsample = 20000;
    if(total_samples > maxsample)
        if(debug == 1)
            disp(['Downsampling an image to ', num2str(maxsample),' points from ', num2str(total_samples)]);
        end
        
        %Get an indexable list of x,y coordinates to downsample
        rand_list_xy = zeros(total_samples,2);
        rand_list_index = 1;
        for y=1:size(cleaned, 1)
            for x=1:size(cleaned,2)
                if(cleaned(y,x) == 1)
                    rand_list_xy(rand_list_index,:) = [y x];
                    rand_list_index = rand_list_index + 1;
                end
            end
        end
         
        %Uniform random sample coordinate points from an image
        rand_list = randsample(total_samples, maxsample);
        clean_tmp = zeros(size(cleaned, 1), size(cleaned, 2));
        for i=1:numel(rand_list)
            y = rand_list_xy(rand_list(i),1);
            x = rand_list_xy(rand_list(i),2);
            clean_tmp(y,x) = 1;
        end
        
        cleaned = clean_tmp;
    end
    
    %Get the count of the connected components
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
        cutoffval = 6;
    end
    if(cutoffval > 30)
        cutoffval = 30;
    end
    if(debug == 1)
        disp(['Cutoffval: ', num2str(cutoffval)]);
    end

    out = clusterdata(output_list, 'cutoff', cutoffval, 'distance', 'euclidean', 'criterion', 'distance');
    cluster_count = histc(out, unique(out));

    if(debug == 1)
        disp(cluster_count);
    end
    
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
        
    %Create the final clusters mask
    final_clusters_mask = zeros(size(final_clusters, 1), size(final_clusters, 2));
        
    %Estimate an ellipses function and then draw it
    for i=1:numel(cluster_count)
        %Ignore any cluster if it is really tiny
        if(cluster_count(i) < 20)
            continue;
        end

        %Get the x,y coordinates for a given cluster
        xs = output_list(out(:) == i, 1);
        ys = output_list(out(:) == i, 2);
        
        %Calculate the mean of each value
        Mu = mean(horzcat(xs, ys));
        %Calculate the distance of each datapoint from the mean in euclidean space
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
        
        %Create a ROI mask from datapoints that form an ellipse estimation
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