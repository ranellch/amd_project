function [ feature_vectors, classes ] = get_fv_od_regions( od_texture_img, pid, eye, time )
%Runs texture based classification and clustering on input image.  Then uses user
%input to classify regions and build feature vectors based on radial vessel
%thickness and density features found in choose_od

addpath('../Circle fit')

disp('---Running Vessel Detection---')
[vessels, angles, ~] = find_vessels(pid, eye, time);

%Remove all classified datapoints that were already classified as a vessel
positive_count = 0;
img_vessels_negatve = bwmorph(vessels, 'thicken', 5);
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
    cluster_img = cluster_texture_regions(od_texture_img);
else
    cluster_img = zeros(size(od_texture_img));
end

%Iterate over all clusters and calculate radial features
numclusters = max(cluster_img(:));
feature_vectors = [];
classes = [];
angles = mod(angles,180);

vskel = bwmorph(vessels,'skel',Inf);

%Get original image for displaying ROIs
img = imread(get_pathv2(pid,eye,time,'original'));
img = crop_footer(img);
img = imresize(img,[size(cluster_img,1),size(cluster_img,2)]);

for i = 1:numclusters
    roi = cluster_img==i;
    roi = imfill(roi,'holes');
    %get user input to label region class
    h = figure; imshowpair(roi,img)
    button = questdlg('Select Class', 'User Input','Positive','Negative','Skip','Positive');
    close(h)
    switch button
        case 'Positive'
            classes = [classes; 1];
        case 'Negative'
            classes = [classes; 0];
        case 'Skip'
            continue
    end
    border_img  = bwperim(roi);
    %get rid of pixels on image border
    border_img(1,:) = 0;
    border_img(:,1) = 0;
    border_img(size(border_img,1),:) = 0;
    border_img(:,size(border_img,2)) = 0;
    %estimate circle from region border
    [y,x] = find(border_img);
    Par = CircleFitByTaubin([x,y]);
    xc = Par(1);
    yc = Par(2);
    R = Par(3);
    circle_img = plot_circle(xc,yc,R, size(cluster_img,2), size(cluster_img,1));
    %calculate portion of circle filled by roi
    ppv = sum(sum(circle_img&roi))/sum(sum(circle_img));
    %calculate portion of roi outside of circle
    fnr = sum(sum(~circle_img&roi))/sum(sum(circle_img));
    %get circle perimeter for dilated circle
	circle_img = plot_circle(xc,yc,R+R/3, size(cluster_img,2), size(cluster_img,1));
    circle_img = bwperim(circle_img);
    %get rid of pixels on image border
    circle_img(1,:) = 0;
    circle_img(:,1) = 0;
    circle_img(size(circle_img,1),:) = 0;
    circle_img(:,size(circle_img,2)) = 0;
    %for all vessel pixels along circle border calculate estimated angles based on circle geometry
    %weight pixels by angle correlation (1-abs[(actual angle)-(estimated_angle)]/180) before summing to obtain density
    weighted_count = 0;
    border_angs = angles(circle_img&vessels);
    numcrossings = sum(sum(circle_img&vskel));
    if numcrossings == 0 
        radial_normal_density = 0;
        radial_normal_thickness = 0;
    else
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
    end
    feature_vector = [R,radial_normal_density,radial_normal_thickness, ppv, fnr];
    feature_vectors = [feature_vectors; feature_vector];
end

end










