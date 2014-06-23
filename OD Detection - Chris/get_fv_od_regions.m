function [ feature_vectors, classes ] = get_fv_od_regions( od_texture_img, pid, eye, time )
%Runs texture based classification and clustering on input image.  Then uses user
%input to classify regions and build feature vectors based on radial vessel
%thickness and density features found in choose_od

[vessels, angles, ~] = find_vessels(pid, eye, time);

%Remove all classified datapoints that were already classified as a vessel
positive_count = 0;
img_vessels_negatve = bwmorph(img_vessel, 'thicken', 5);
for y=1:size(od_texture_img,1)
    for x=1:size(od_texture_img,2)
        if(img_vessels_negatve(y,x) == 1)
            od_texture_img(y,x) = 0;
        end
        if(od_texture_img(y,x) == 1)
            positive_count = positive_count + 1;
        end
    end
end

%Run the clustering algorithm if there are regions to cluster
if(positive_count > 10)
    cluster_img = cluster_texture_regions(od_image, debug);
else
    cluster_img = zeros(size(od_texture_img));
end

%Iterate over all clusters and calculate radial features
numclusters = max(cluster_img(:));
feature_vectors = [];
classes = [];
angles = mod(angles,180);

vskel = bwmorph(vessels,'skel',Inf);
for i = 1:numclusters
    roi = cluster_img==i;
    roi = imfill(roi,'holes');
    img = imread(get_pathv2(pi,eye,time,'original');
    img = rgb2gray(img);
    img = crop_footer(img);
    img = imresize(img,[size(roi,1),size(roi,2)]);
    h=figure; imshowpair(img,roi)
    button = questdlg('Select Class','User Input', 'Positive','Negative', 'Skip','Positive');
    close(h)
    switch button
        case 'Positive'
            class = 1;
        case 'Negative'
            class = 0;
        case 'Skip'
            continue
    end
    classes = [classes; class];
    border_img  = bwperim(roi);
    %get rid of pixels on image border
    border_img(1,:) = 0;
    border_img(:,1) = 0;
    border_img(size(border_img,1),:) = 0;
    border_img(:,size(border_img,2)) = 0;
    %estimate circle from elipse border
    [y,x] = find(border_img);
    Par = CircleFitByTaubin([x,y]);
    xc = Par(1);
    yc = Par(2);
    R = Par(3);
    circle_img = plot_circle(xc,yc,R+R/3, size(cluster_img,2), size(cluster_img,1));
    %for all vessel pixels along circle border calculate estimated angles based on circle geometry
    %weight pixels by angle correlation (1-abs[(actual angle)-(estimated_angle)]/180) before summing to obtain density
    weighted_count = 0;
    border_angs = angles(circle_img&vessels);
    numcrossings = sum(sum(circle_img&vskel));
    for j = 1:length(border_angs)
        [y,x] = ind2sub(size(angles),j);
        ang1 = border_angs(j);
        ang2 = atan2d(yc-y,x-xc);
        diff = min([abs(ang1 - ang2), 180 - abs(ang1 - ang2)]);
        correlation = 1 - diff/180.0;
        weighted_count = weighted_count + correlation;
    end
    radial_normal_density = weighted_count/sum(sum(circle_img));
    radial_normal_thickness = weighted_count/numcrossings;
    feature_vector = [R,radial_normal_density,radial_normal_thickness];
    feature_vectors = [feature_vectors; feature_vector];
end

t = (cputime-e)/60.0;
if(debug == 1 || debug == 2)
    disp(['Time to analyze classified regions (min): ' num2str(t)])
end


end

function circle_img = plot_circle(xc,yc,R, max_x, max_y)
circle_img = zeros(max_y,max_x);
for y  = 1:max_y
    for x = 1:max_x
        if (x-xc)^2+(y-yc)^2 < (R+.5)^2 && (x-xc)^2+(y-yc)^2 > (R-.5)^2
            circle_img(y,x) = 1; 
        end
    end
end
end







