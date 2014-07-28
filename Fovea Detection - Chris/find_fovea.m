function [ x_fov,y_fov, varargout ] = find_fovea( vessels, angles, od, varargin )

if nargin == 3
    debug = 1;
else 
    debug = varargin{1};
end

addpath('../Skeleton')
addpath('../Circle fit');

if debug == 1|| debug == 2
    disp('[FOV] Estimating Location of Fovea')
    time = cputime;
end

%skeltonize vessels
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);

%caclulate vessel thicknesses
[thickness_map, ~] = plot_vthickness( vessels, vskel, angles );
% 
% if debug == 2
%     figure(7), subplot(2,2,1), imagesc(thickness_map), title('Vessel Thickness Map')
%     colormap(jet)
% end

%fit circle to od border and get estimated center coordinate to define
%parabola vertex
od_perim = bwperim(od);
[y,x] = find(od_perim);
Par = CircleFitByTaubin([x,y]);
xc = Par(1);
yc = Par(2);

%Put image in normal coordinates centered at optic disk
[xcorr,ycorr] = meshgrid((1:size(vessels,2)) - xc, yc - (1:size(vessels,1)));

%get skeletonize vessel corrdinates for fitting
x = xcorr(vskel);
y = ycorr(vskel);
points = [x,y];

%Fit parabola using ransac for point selection
%Note that degenfn has been replaced by a dummy function that always returns 1
if debug == 1|| debug == 2
    disp('[RANSAC] Estimating Parabola')
    tr = cputime;
end

s = 400;
t = 50;
maxTrials = 500;
[M, inliers] = ransac(points', @fitParabola, @distfn, @dummy, s, t, 0, 2, maxTrials);
a = M(1)
B = M(2)

if debug == 1|| debug == 2
    e = cputime-tr;
    disp(['Parabola Estimation Time(min): ',num2str(e/60.0)])
end


xprime = zeros(size(vessels));
yprime = zeros(size(vessels));
%put entire image in new coordinate system
for i = 1:size(vessels,1)
    for j = 1:size(vessels,2)
        if B == 0
            xprime(i,j) = xcorr(i,j);
            yprime(i,j) = ycorr(i,j);
        else
            xprime(i,j) = (xcorr(i,j)*cosd(B)+ycorr(i,j)*sind(B))/(sind(B)^2+cosd(B)^2);
            yprime(i,j) = (xprime(i,j)*cosd(B)-xcorr(i,j))/sind(B);
        end
    end
end
                   
%calculate parabola
ydomain = min(yprime(:)):max(yprime(:));
if sum(xprime>0) > sum(xprime<0)
    f_y = round(a*ydomain.^2); %right facing parabola
    move_right = true;
else
    f_y = round(-1*a*ydomain.^2); %left facing parabola
    move_right = false;
end
if debug == 2
%     h=figure(8);
    h = figure('Visible','off');
    imshow(vessels);
    hold(gca,'on')    
    % get original indices for inlier points
    inliers = [x(inliers)+xc,yc-y(inliers)];
    % show parabola points
    for i = 1:length(ydomain) 
        [y,x] = find((round(f_y(i))==round(xprime)) & (round(ydomain(i)) == round(yprime)));
        plot( x,y,'r.');
    end
     plot(inliers(:,1),inliers(:,2),'mx')
end

if nargout == 5
    varargout{1} = h;
    varargout{2} = B;
    varargout{3} = [xc,yc];
end


%create vessel density map
density_map = plot_vdensity(vessels);
% if debug == 2
%     figure(7), subplot(2,2,2), imagesc(density_map), title('Vessel Density Map')
% end

%Combine density and thickness, and use moving average filter along raphe
%line to find minimum as most likely fovea location
combined_map = density_map.*thickness_map;
% if debug == 2
%     figure(7), subplot(2,2,3,'position',[.275 .05 .45 .45]), imagesc(combined_map),  title('Combined Map')
% end

%count votes for what side to start on
if move_right
    %get x,y coordinates along raphe line pointing towards fovea
    [y_raphe,x_raphe] = find(round(yprime)==0 & xprime>0 & ~od);
    if debug == 1 || debug == 2
        disp('Fovea is to the right of the optic disk')
    end
else
    %get x,y coordinates along raphe line pointing towards fovea
    [y_raphe,x_raphe] = find(round(yprime)==0 & xprime<0 & ~od);
    if debug == 1 || debug ==2
        disp('Fovea is to the left of the optic disk')
    end
end

if debug == 2
    plot(x_raphe,y_raphe,'b-');
end

indices = [x_raphe,y_raphe];
xprime_raphe = zeros(length(x_raphe),1);
for i = 1:length(x_raphe)
    xprime_raphe(i) = xprime(y_raphe(i),x_raphe(i));
end
sortinfo = [indices, xprime_raphe];
combined_vals = zeros(size(indices,1),1);    
sortinfo = sortrows(sortinfo,3);
indices = sortinfo(:,1:2);
for i = 1:size(indices,1)
    x = indices(i,1);
    y = indices(i,2);
    combined_vals(i) = combined_map(y,x);
end
% if debug == 2
%     figure(9), plot(1:length(combined_vals),combined_vals), title('Raphe Line Moving Average Values')
% end

%Find all minima
values = max(combined_vals) - combined_vals;
threshold1 = .1*(max(values)-min(values));
threshold2 = .5*(max(values)-min(values));
delta = 50;
MinIdx = findPeaksEasy(values, threshold1, threshold2, delta);
if isempty(MinIdx)
    x_fov = -1;
    y_fov = -1;
    return
end

%Take biggest one 
x_fov = indices(MinIdx(1),1);
y_fov = indices(MinIdx(1),2);

if debug == 2
    plot(x_fov,y_fov,'gd','MarkerSize',10)
    hold(gca,'off')
end


if debug == 1|| debug == 2
    e = cputime-time;
    disp(['Fovea Estimation Time(min): ',num2str(e/60.0)])
end


%dummy function for ransac framework 
function r = dummy(~)
    r = 0;



