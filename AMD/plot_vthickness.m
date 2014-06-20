function [ thickness_map ] = plot_vthickness( vessels, angles )
addpath('../Skeleton')

disp('Generating vessel thickness plot')
e = cputime;
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);
[sky,skx] = find(vskel);
%get junctions to ignore
[~,~,jxy] = anaskel(vskel);
[origy, origx] = size(vessels);

angles = mod(angles,180);
%get vessel thickness interpolated over entire image
thickness_map = zeros(size(vessels));
for i = 1:4:length(sky)
    y = sky(i);
    x = skx(i);
    %check if within 10 pixels of junction, if so skip this point
    if any(abs(jxy(1,:)-x)<10 & abs(jxy(2,:)-y) < 10)
        continue
    end
    %draw line perpendicular to angle at this point and count
    %number of orthogonal vessel pixels 
    ortho_ang = angles(y,x)+90.0;
    if ortho_ang > 90
        ortho_ang = ortho_ang - 180;
    end
    on_vessel = true;
    r = 0;
     while on_vessel
       r = r + 1;
        delta_x = round(r*cosd(ortho_ang));
        delta_y = round(r*sind(ortho_ang));
        if y-delta_y < 1 || y-delta_y > size(vessels,1) || x+delta_x < 1 || x+delta_x > size(vessels,2)
            on_vessel = false;
        else
            if vessels(y-delta_y,x+delta_x) == 1
                thickness_map(y,x) = thickness_map(y,x) + 1;
            else
                on_vessel = false;
            end
        end    
     end
     r = 0;
     on_vessel = true;
    while on_vessel
        r = r - 1;
        delta_x = round(r*cosd(ortho_ang));
        delta_y = round(r*sind(ortho_ang));
        if y-delta_y < 1 || y-delta_y > size(vessels,1) || x+delta_x < 1 || x+delta_x > size(vessels,2)
            on_vessel = false;
        else
            if vessels(y-delta_y,x+delta_x) == 1
                thickness_map(y,x) = thickness_map(y,x) + 1;
            else
                on_vessel = false;
            end
        end 
    end
end
%  figure, imshow(thickness_map)
    %interpolate
    thickness_map = padarray(thickness_map,[150 150], 'symmetric');
    [y, x, T] = find(thickness_map);
    y = y - 150; %adjust for padding
    x = x - 150;
    [xq, yq] = meshgrid(1:size(vessels,1), 1:size(vessels,2));
    thickness_map = griddata(x, y, T, xq, yq, 'natural');
    t = (cputime - e)/60.0;
    disp(['Time to generate thickness plot (min): ', num2str(t)])

end

