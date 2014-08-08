function [ x_fov, y_fov, varargout ] = find_fovea_no_od ( vessels, angles, varargin )
%Finds estimated fovea find_od failed because od is
%perhaps not present in the image
if nargin == 2
    debug = 1;
else 
    debug = varargin{1};
end

if debug > 0 
    disp('[FOV] Estimating Location of Fovea sans OD')
    time = cputime;
end

addpath('../Skeleton')

%skeletonize vessels
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);

%caclulate vessel thicknesses
[thickness_map, ~] = plot_vthickness( vessels, vskel, angles );

 if debug == 2
    figure(7), subplot(2,2,1), imagesc(thickness_map), title('Vessel Thickness Map')
     colormap(jet)
 end

%create vessel density map
density_map = plot_vdensity(vessels);
 if debug == 2
    figure(7), subplot(2,2,2), imagesc(density_map), title('Vessel Density Map')
 end

%Combine density and thickness, and use moving average filter along raphe
%line to find broadest minimum as most likely fovea location
combined_map = density_map.*thickness_map;
 if debug == 2
     figure(7), subplot(2,2,3,'position',[.275 .05 .45 .45]), imagesc(combined_map),  title('Combined Map')
 end


%find minimum in each column of the thickness/density map
%run linear regression on these points
points = [];
tol = 1e-4;
for i = 1:size(combined_map,2)
	col = combined_map(:,i);
	col = max(col)-col;
	col = smooth(col);
	idx = findMaxPeakEasy(col, tol);
    if ~isempty(idx)    
        points = [points; idx,i]; 
    end
end

%fit raphe line
y = points(:,1);
x = points(:,2);
b = ones(size(x));
A = [x b];
c = A\y;

%plot raphe line
x= 1:size(combined_map,2);
y = zeros(size(x));
for i=1:length(x);
	y(i) = round(c(1)*i+c(2));
end
%get final raphe line, discarding uninterpolated points
raphe_x=[];
raphe_y=[];
for i=1:length(x)
    if ~isnan(combined_map(y(i),x(i)))
        raphe_x=[raphe_x,x(i)];
        raphe_y=[raphe_y,y(i)];
    end
end

if debug >= 2
     h=figure(8);
    imshow(vessels);
    hold(gca,'on')    
    % show estimated raphe line
     plot(x,y,'b-')
end

if nargout == 3
	varargout{1} = h;
end

%get values along estimated raphe line 
raphe_vals = zeros(size(raphe_x));
for i = 1:length(raphe_x)
    raphe_vals(i) = combined_map(raphe_y(i),raphe_x(i));
end

%find minimum along line
raphe_vals = smooth(raphe_vals);
raphe_vals = max(raphe_vals)-raphe_vals;
tol = 1e-4;
MinIdx = findMaxPeakEasy(raphe_vals, tol);
if isempty(MinIdx)
    x_fov = -1;
    y_fov = -1;
    return
end

x_fov = raphe_x(MinIdx);
y_fov = raphe_y(MinIdx);

if debug >= 2
    figure(8)
    plot(x_fov,y_fov,'gd','MarkerSize',10)
    hold(gca,'off')
end

if debug > 0
    e = cputime-time;
    disp(['Fovea Estimation Time(min): ',num2str(e/60.0)])
end

	
