function [ img_out ] = find_od_window( pid, eye, time  )
% Finds optic disk region of interest

addpath('..');
addpath(genpath('../Test Set'));
addpath('../Vessel Detection - Chris');

%Get vessels and angles of greatest lineop strength
[vessels, angles] = find_vessels(pid, eye, time);
figure, imshow(vessels)

angles(~vessels) = 0;
angles = mod(angles,180);

%Interpolate
[y, x, angs] = find(angles);
[xq, yq] = meshgrid(1:768, 1:768);
angle_map = griddata(x, y, angs, xq, yq,'cubic');
figure, imshow(mat2gray(angle_map))

%Run correlation on this mofo
od_filter = load('od_masks', 'mask_mirrored');
od_filter = od_filter.mask_mirrored;

diff_img = zeros(size(angle_map));
angle_map = padarray(angle_map, [150 150], 'symmetric', 'both');
for y = 1:16:768
    for x = 1:16:768
        diff_img(y,x) = sum(sum(angle_map(y:y+299,x:x+299)-od_filter));
    end
end

figure, imshow(mat2gray(diff_img))

[min_y, min_x, ~] = find(diff_img==min(diff_img(:)));

%Draw box 
img_out = imread(get_pathv2(pid,eye,time,'original'));
img_out = imresize(img_out, [768 768]);

figure, imshow(img_out)
hold on
plot(min_x,min_y,'marker','x', 'MarkerSize', 40)

end

