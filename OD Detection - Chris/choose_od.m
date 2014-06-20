function [ candidate_region, max_od_strength ] = choose_od( od_img, vessels, angles,varargin )
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

%Get vessels and angles of greatest lineop strength
angles(~vessels) = 0;
angles = mod(angles,180);

%Find best region
od_img = labelmatrix(bwconncomp(od_img));

if(debug == 1 || debug == 2)
    disp('Running region analysis')
end

e = cputime;
%Iterate over all elipses and calculate radial vessel density and
%vessel angularity along border
numelipses = max(od_img(:));
border_density = zeros(numelipses,1);
angle_diff = zeros(numelipses,1);
if debug == 2
    figure(6), imagesc(od_img)
    hold on
end

for i = 1:numelipses
    roi = od_img==i;
    border_img  = bwperim(roi);
    %get rid of pixels on image border
    border_img(1,:) = 0;
    border_img(:,1) = 0;
    border_img(size(border_img,1),:) = 0;
    border_img(:,size(border_img,2)) = 0;
    %estimate circle from elipse border
    [y,x] = find(border_img);
    [xc,yc,R,~] = circfit(x,y);
    circle_img = plot_circle(xc,yc,R+50, max_x, max_y);
    circle_perim = bwperim(circle_img);
    if debug == 2
        [cy,cx] = find(circle_perim);
        plot(cx,cy,'r.')
    end
    %get density of vessel pixels touching circle
    border_density(i) = sum(sum(circle_perim&vessels))/sum(sum(circle_perim));
    %for all vessel pixels between elipse border and circle border calculate estimated angles and see how
    %vessels match up 
    tb  = yc - R;
    if tb < 1
        tb = 1;
    end
    bb = yc + R;
    if bb > size(border_img,1);
        bb = size(border_img,1);
    end
    lb = xc - R;
    if lb < 1
        xc = 1;
    end
    rb = xc + R;
    if rb > size(border_img,2);
        rb = size(border_img,2);
    end
    roi_angles = circle_img(tb:bb,lb:rb) & angles(tb:bb,lb:rb);
    expected_angles = estimate_angles(R, roi_angles);
    angle_diff(i) = sum(sum(roi_angles - expected_angles())/((bb-tb)*(rb-lb));
end
if debug == 2
    hold off
end

t = (cputime-e)/60.0;
if(debug == 1 || debug == 2)
    disp(['Time to analyze classified regions (min): ' num2str(t)])
end

%Only keep region containing max correlation
strength_img = max(strength_img,[],3);
max_od_strength = max(strength_img(:));
[max_y, max_x, ~] = find(strength_img==max_od_strength);
if debug == 2
    figure(5), imshow(mat2gray(strength_img))
    hold on
    plot(max_x,max_y,'gx')
    hold off
end
candidate_region = zeros(size(od_img)); 
for y = 1:size(od_img,1)
    for x = 1:size(od_img,2)
        if od_img(y,x) == od_img(max_y,max_x);
            candidate_region(y,x) = 1;
        end
    end
end
candidate_region = logical(candidate_region);

end

function circle_img = plot_circle(xc,yc,R, max_x, max_y)
circle_img = zeros(max_y,max_x);
for y  = 1:max_y
    for x = 1:max_x
        if (x-xc)^2+(y-yc)^2 <= R
            circle_img(y,x) = 1; 
        end
    end
end
end

function [mask] = estimate_angles(size) 
mask = zeros(size);
if mod(size,2) == 1
    [xcorr, ycorr] = meshgrid(-floor(size/2):floor(size/2),floor(size/2):-1:-floor(size/2));
else
    [xcorr, ycorr] = meshgrid(-size/2+1:size/2,size/2-1:-1:-size/2);
end
 for y = 1:size
    for x = 1:size
        if sqrt(xcorr(y,x)^2+ycorr(y,x)^2) > floor(size/3)
         mask(y,x) = atan2d(ycorr(y,x),xcorr(y,x));
        end
    end
 end
  mask=mod(mask,180);
end

