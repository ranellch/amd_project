function [ y,x ] = find_fovea( vessels, angles, od, varargin )

if nargin == 3
    debug = 1;
else 
    debug = varargin{1};
end

addpath('../Skeleton')
addpath('../Circle fit');

if debug == 1|| debug == 2
    disp('Estimating Location of Fovea')
    t = cputime;
end

%skeltonize vessels
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);

%caclulate vessel thicknesses
[thickness_map, v_thicknesses] = plot_vthickness( vessels, vskel, angles );

if debug == 2
    figure(7), imagesc(thickness_map)
end

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

%find all points of thick vessels (>6 pixels)
figure, imshow(thickness_map>8)
[y,x] = find(thickness_map>8);

%find parameters a and b to best fit parabola
a0 = 0.0032;
B0 = 0;
options = optimoptions('lsqnonlin');
options.Algorithm = 'levenberg-marquardt';
options.TolFun = 1e-9;
params = lsqnonlin(@parabola_criterion,[a0,B0],[],[],options);
a = params(1)
B = params(2)

%put entire image in new coordinate system
xprime = zeros(size(vessels));
yprime = zeros(size(vessels));
for y = 1:size(vessels,1)
    for x = 1:size(vessels,2)
        xprime(y,x) = (x*cosd(B)+y*sind(B))/(cosd(B)^2+sind(B)^2);
        yprime(y,x) = (xprime(y,x)*cosd(B)-x)/sind(B);
    end
end

%center at optic disk
xcprime = (xc*cosd(B)+yc*sind(B))/(cosd(B)^2+sind(B)^2);
ycprime = (xcprime*cosd(B)-xc)/sind(B);
xprime = xprime - xcprime;
yprime = yprime - ycprime;

%plot parabola
if debug == 2
    y_domain = min(yprime(:)):max(yprime(:));
    f_y = zeros(length(y_domain),2);
    f_y(:,1) = round(a*y_domain.^2);
    f_y(:,2) = round(-1*a*y_domain.^2);
    figure(8)
    imshow(vessels)
    hold on
    for i = 1:length(f_y)
        [y,x] = find(round(yprime)==round(y_domain(i))&round(xprime)==round(f_y(i,1)));
        if ~isempty(y)
            plot(x,y,'r.')
        end
        [y,x] = find(round(yprime)==round(y_domain(i))&round(xprime)==round(f_y(i,2)));
        if ~isempty(y)
            plot(x,y,'r.')
        end
        [y,x] = find(round(yprime)==0);
        if ~isempty(y)
            plot(x,y,'b-')
        end
    end
    hold off
end

%create vessel density map
density_map = plot_vdensity(vessels);
if debug == 2
    figure(9), imagesc(density_map)
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
        
        xcprime = xc;
        ycprime = yc;
    else
        %get x and y values in new rotated coordinate system
        xprime = (x*cosd(B)+y*sind(B))/(cosd(B)^2+sind(B)^2);
        yprime = (xprime*cosd(B)-x)/sind(B);
        
        xcprime = (xc*cosd(B)+yc*sind(B))/(cosd(B)^2+sind(B)^2);
        ycprime = (xcprime*cosd(B)-xc)/sind(B);
    end
    
    J = a*((xprime-xcprime)*sind(B)+(yprime-ycprime)*cosd(B)).^2 ...
            - ((xprime-xcprime)*cosd(B)-(yprime-ycprime)*sind(B));    
end
end