function [ y,x ] = find_fovea( vessels, angles, od )

addpath('../Skeleton')
addpath('../Circle fit');

%skeltonize vessels
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);

%fit circle to od border and get estimated center coordinate to define
%parabola vertex
od_perim = bwperim(od);
od_perim(:,1)=0;
od_perim(1,:)=0;
od_perim(:,size(od_perim,2))=0;
od_perim(size(od_perim,1),:)=0;
[y,x] = find(od_perim);
Par = CircleFitByTaubin([x,y]);
xc = Par(1);
yc = Par(2);

%find all skeleton points
[y,x] = find(vskel);

%define parabola function
parabola = @

thickness_map = plot_vthickness( vessels, vskel, angles );


end

