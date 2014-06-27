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

%find all skeleton points
[y,x] = find(vskel);

%find parameters a and b to best fit parabola
a0 = 0.0032;
B0 = 0;
[params,fval] = fminsearch(@parabola_criterion,[a0,B0]);
a = params(1);
B = params(2); 

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
    figure, imshow(vessels)
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
    end
    hold off
end



% thickness_map = plot_vthickness( vessels, vskel, angles );

if debug == 1|| debug == 2
    e = cputime-t;
    disp(['Time(sec): ',num2str(e)])
end


%define parabola function
function J = parabola_criterion(inits)
    a = inits(1);
    B = inits(2);
    %get x and y values in new rotated coordinate system
    xprime = (x*cosd(B)+y*sind(B))/(cosd(B)^2+sind(B)^2);
    yprime = (xprime*cosd(B)-x)/sind(B);
    
    xcprime = (xc*cosd(B)+yc*sind(B))/(cosd(B)^2+sind(B)^2);
    ycprime = (xcprime*cosd(B)-xc)/sind(B);
    
    J = sum(abs(a*((xprime-xcprime)*sind(B)+(yprime-ycprime)*cosd(B)).^2 ...
            - ((xprime-xcprime)*cosd(B)-(yprime-ycprime)*sind(B))));
end
end