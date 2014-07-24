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
    t = cputime;
end

%skeltonize vessels
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);

%caclulate vessel thicknesses
[thickness_map, v_thicknesses] = plot_vthickness( vessels, vskel, angles );
% 
% if debug == 2
%     figure(7), subplot(2,2,1), imagesc(thickness_map), title('Vessel Thickness Map')
% end

%fit circle to od border and get estimated center coordinate to define
%parabola vertex
od_perim = bwperim(od);
od_perim(:,1:10)=0;
od_perim(1:10,:)=0;
od_perim(:,size(od_perim,2)-9:end)=0;
od_perim(size(od_perim,1)-9:end,:)=0;
[y,x] = find(od_perim);
Par = CircleFitByTaubin([x,y]);
xc = Par(1);
yc = Par(2);

%Put image in normal coordinates centered at optic disk
[xcorr,ycorr] = meshgrid((1:size(vessels,2)) - xc, yc - (1:size(vessels,1)));

%find all points of thick vessels (>7 pixels)
% figure, imshow(v_thicknesses>7)
points = find(v_thicknesses>5);
x = xcorr(points);
y = ycorr(points);

%find parameters a and b to best fit parabola
a0 = 0.003;
B0 = 0;
options = optimoptions('lsqnonlin');
% options.Algorithm = 'levenberg-marquardt';
options.TolFun = 1e-9;
options.TolX = 1e-12;
params = lsqnonlin(@parabola_criterion,[a0,B0],[],[],options);
a = params(1)
B = params(2)

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


%plot parabola
y_domain = min(yprime(:)):max(yprime(:));
f_y = zeros(length(y_domain),2);
f_y(:,1) = round(a*y_domain.^2); %right facing parabola
f_y(:,2) = round(-1*a*y_domain.^2); %left facing parabola
if debug == 2
    %h=figure(8)
    h = figure('Visible','off');
    imshow(vessels);
    hold(gca,'on')
    for y = 1:size(yprime,1)
        for x = 1:size(xprime,2)
            for i = 1:length(y_domain) 
                 if (round(xprime(y,x)) == f_y(i,1) || round(xprime(y,x)) == f_y(i,2)) ...
                        && round(yprime(y,x)) == round(y_domain(i))
                    plot( x,y,'r.');
                    break
                 end
            end
        end
    end
     [r,c] = ind2sub(size(vessels),points);
     plot(c,r,'mx')
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
size(density_map), size(thickness_map)
combined_map = density_map.*thickness_map;
% if debug == 2
%     figure(7), subplot(2,2,3,'position',[.275 .05 .45 .45]), imagesc(combined_map),  title('Combined Map')
% end

%count votes for what side to start on
move_right = sum(f_y(:,1)<max(xprime(:))&f_y(:,1)>min(xprime(:)));
move_left = sum(f_y(:,2)<max(xprime(:))&f_y(:,2)>min(xprime(:)));
if move_right > move_left
    move_right = true;
    %get x,y coordinates along raphe line pointing towards fovea
    [y_raphe,x_raphe] = find(round(yprime)==0 & xprime>0);
    if debug == 1 || debug == 2
        disp('Fovea is to the right of the optic disk')
    end
else
    move_right = false;
    %get x,y coordinates along raphe line pointing towards fovea
    [y_raphe,x_raphe] = find(round(yprime)==0 & xprime<0);
    if debug == 1 || debug ==2
        disp('Fovea is to the left of the optic disk')
    end
end

if debug == 2
    plot(x_raphe,y_raphe,'b-');
end

winsiz = 200;
padded_combined = padarray(combined_map,[winsiz/2 winsiz/2],'symmetric');
indices = [x_raphe,y_raphe];
combined_avg = zeros(size(indices,1),1);    
if move_right
    indices = sortrows(indices,1);
else
    indices = sortrows(indices,-1);
end
for i = 1:size(indices,1)
    x = indices(i,1);
    y = indices(i,2);
    combined_avg(i) = mean2(padded_combined(y:y+winsiz-1,x:x+winsiz-1));
end
% if debug == 2
%     figure(9), plot(1:length(combined_avg),combined_avg), title('Raphe Line Moving Average Values')
% end

%Find all minima
values = max(combined_avg) - combined_avg;
threshold = min(values) + 0.25*(max(values)-min(values));
values = smooth(values,20,'lowess');
[~,MinIdx] = findpeaks(values,'MinPeakHeight',threshold);
if isempty(MinIdx)
    x_fov = -1;
    y_fov = -1;
    return
end

%Take first one (points ordered from distance away from OD) as the location of the fovea
x_fov = indices(MinIdx(1),1);
y_fov = indices(MinIdx(1),2);

if debug == 2
    plot(x_fov,y_fov,'gd','MarkerSize',10)
    hold(gca,'off')
end


if debug == 1|| debug == 2
    e = cputime-t;
    disp(['Fovea Estimation Time(sec): ',num2str(e)])
end


%define parabola fitting function
function J = parabola_criterion(inits)
    a = inits(1);
    B = inits(2);
    if B == 0
        xprime = x;
        yprime = y;
    else
        %get x and y values in new rotated coordinate system
        xprime = (x*cosd(B)+y*sind(B))/(sind(B)^2+cosd(B)^2);
        yprime = (xprime*cosd(B)-x)/sind(B);
    end
    
    J = a*(xprime*sind(B)+yprime*cosd(B)).^2 ...
            - abs(xprime*cosd(B)-yprime*sind(B));    
end
end
