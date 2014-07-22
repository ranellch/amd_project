function [ candidate_region, od_probability ] = choose_od( cluster_img, vessels, angles,varargin )
debug = -1;
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
end
    
% Finds optic disk region of interest

addpath('..');
addpath('../Circle fit');

%Load region classifier
model = load('od_classifiers.mat','region_classifier');
classifier = model.region_classifier;

if(debug == 1 || debug == 2)
    disp('Running region analysis')
end

e = cputime;
%Iterate over all clusters and calculate radial features
numclusters = max(cluster_img(:));
angles = mod(angles,180);
if debug == 2
    feature_img = cluster_img;
    feature_img(vessels) = numclusters+1;
    figure(3), imagesc(feature_img)
    hold on
end

index = -1;
for i = 1:numclusters
    roi = cluster_img==i;
    se = strel('disk',10);
    roi = imclose(roi,se);
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
	circle_img = plot_circle(xc,yc,R+R/2, size(cluster_img,2), size(cluster_img,1));
    circle_border = bwperim(circle_img);
    %get rid of pixels on image border
    circle_border(1,:) = 0;
    circle_border(:,1) = 0;
    circle_border(size(circle_border,1),:) = 0;
    circle_border(:,size(circle_border,2)) = 0;
    %show circles if specified
    if debug == 2
        [cy,cx] = find(circle_border);
        plot(cx,cy,'r.')
        [by,bx] = find(border_img);
        plot(bx,by,'w.')
    end 
    %for all vessel pixels along circle border calculate estimated angles based on circle geometry
    %weight pixels by angle correlation (1-abs[(actual angle)-(estimated_angle)]/90) before summing to obtain density
    weighted_count = 0;
    [y,x,~] = find(circle_border&vessels);
    for j = 1:length(y)
            ang1 = angles(y(j),x(j));
            ang2 = atan2d(yc-y(j),x(j)-xc);
            diff = min([abs(ang1 - ang2), 180 - abs(ang1 - ang2)]);
            correlation = 1 - diff/90.0;
            weighted_count = weighted_count + correlation;
    end
    radial_normal_density = weighted_count/sum(sum(circle_border));
    if isnan(radial_normal_density)
        radial_normal_density = 0;
    end
    [y,x,~] = find(circle_img&vessels&~circle_border);
    for j = 1:length(y)
            ang1 = angles(y(j),x(j));
            ang2 = atan2d(yc-y(j),x(j)-xc);
            diff = min([abs(ang1 - ang2), 180 - abs(ang1 - ang2)]);
            correlation = 1 - diff/90.0;
            weighted_count = weighted_count + correlation;
    end     
     interior_alignment= weighted_count/sum(sum(circle_img&vessels));
     if isnan(interior_alignment)
         interior_alignment=0;
     end
    feature_vector = [R,radial_normal_density,interior_alignment, ppv, fnr];
    [post,class] = posterior(classifier,feature_vector);
    %get probability of being in class "1"
    od_probability = post(2);
    if class == 1 && od_probability > 0.7
        index = i;
         break
    elseif i == numclusters 
        index = -1;
        od_probability = -1;
    end
end
if debug == 2
    hold off
end

t = (cputime-e)/60.0;
if(debug == 1 || debug == 2)
    disp(['Time to analyze classified regions (min): ' num2str(t)])
end

candidate_region = zeros(size(cluster_img)); 
for y = 1:size(cluster_img,1)
    for x = 1:size(cluster_img,2)
        if cluster_img(y,x) == index;
            candidate_region(y,x) = 1;
        end
    end
end
candidate_region = logical(candidate_region);

end



