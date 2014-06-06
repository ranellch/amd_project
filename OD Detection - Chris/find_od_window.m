function [ candidate_region ] = find_od_window( pid, eye, time  )
% Finds optic disk region of interest

addpath('..');
addpath(genpath('../Test Set'));
addpath('../Vessel Detection - Chris');

%Get vessels and angles of greatest lineop strength
[vessels, angles] = find_vessels(pid, eye, time);
figure, imshow(vessels)

[origy, origx] = size(angles);
vskel = bwmorph(vessels,'skel',Inf);
angles(~vskel) = 0;
angles = mod(angles,180);
angles = padarray(angles, [origy origx], 'symmetric', 'both');

%Interpolate
[y, x, angs] = find(angles);
[xq, yq] = meshgrid(1:size(angles,2), 1:size(angles,1));
angle_map = griddata(x, y, angs, xq, yq,'cubic');
angle_map = angle_map(origy+1:origy+origy,origx+1:origx+origx);
% figure, imshow(mat2gray(angle_map))

%Run correlation on this mofo
od_filter = load('od_masks', 'mask200', 'mask300', 'mask400');

disp('Running correlation')
e = cputime;
scales = [200 300 400];
diff_img = zeros(origy, origx,length(scales));
for k = 1:length(scales)
    angle_map = padarray(angle_map, [scales(k)/2 scales(k)/2], 'symmetric', 'both');
    for y = 1:16:768
        for x = 1:16:768
            diff_img(y,x,k) = corr2(angle_map(y:y+scales(k)-1,x:x+scales(k)-1),od_filter.(['mask',num2str(scales(k))]));
        end
    end
end
t = (cputime-e)/60.0;
disp(['Time to run correlation: ' num2str(t)])


[diff_img, index] = max(diff_img,[],3);
[max_y, max_x, ~] = find(diff_img==max(diff_img(:)));

%Draw box 
candidate_region = zeros(origy, origx);
top = max_y-scales(index(max_y,max_x))/2;
if top<1
    top = 1;
end
bottom = max_y+scales(index(max_y,max_x))/2-1;
if bottom>origy
    bottom=origy;
end
left = max_x-scales(index(max_y,max_x))/2;
if left<1
    left = 1;
end
right = max_x+scales(index(max_y,max_x))/2-1;
if right > origx
    right = origx;
end
candidate_region(top:bottom,left:right) = 1;
candidate_region = logical(candidate_region);


%show center of region of interest
img_out = imread(get_pathv2(pid,eye,time,'original'));
img_out = imresize(img_out, [origy origx]);

figure, imshow(img_out)
hold on
plot(max_x,max_y,'marker','x', 'MarkerSize', 40)

end

