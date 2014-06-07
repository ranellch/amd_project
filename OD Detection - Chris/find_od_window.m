function [ candidate_region ] = find_od_window( pid, eye, time  )
% Finds optic disk region of interest

addpath('..');
addpath(genpath('../Test Set'));
addpath('../Vessel Detection - Chris');

%Get vessels and angles of greatest lineop strength
[vessels, angles] = find_vessels(pid, eye, time);
figure, imshow(vessels)
vskel = bwmorph(vessels,'skel',Inf);
angles(~vskel) = 0;

[origy, origx] = size(angles);
angles = mod(angles,180);
 maxpad = 100;
 angles = padarray(angles, [maxpad maxpad], 'symmetric', 'both');
% 
 %adjust "mirroring" so angles translate over
angles(1:maxpad,maxpad:2*maxpad-1) = 180 - angles(1:maxpad,maxpad:2*maxpad-1);
angles(2*maxpad:2*maxpad+maxpad-1,maxpad:2*maxpad-1) = 180 - angles(2*maxpad:2*maxpad+maxpad-1,maxpad:2*maxpad-1);
angles(maxpad:2*maxpad-1,1:maxpad) = 180 - angles(maxpad:2*maxpad-1,1:maxpad);
angles(maxpad:2*maxpad-1,2*maxpad:2*maxpad+maxpad-1) = 180 - angles(maxpad:2*maxpad-1,2*maxpad:2*maxpad+maxpad-1); 
angles = mod(angles,180);

%Interpolate
[y, x, angs] = find(angles);
[xq, yq] = meshgrid(1:size(angles,2), 1:size(angles,1));
angle_map = griddata(x, y, angs, xq, yq,'cubic');
angle_map = angle_map(maxpad+1:maxpad+origy,maxpad+1:maxpad+origx);
 figure, imshow(mat2gray(angle_map))

%Run correlation on this mofo
od_filter = load('od_masks', 'mask200', 'mask300', 'mask400');

disp('Running correlation')
e = cputime;
scales = [200 300 400];
diff_img = zeros(origy, origx,length(scales));
for k = 1:length(scales)
%     angle_map = padded_angle_map(maxpad+1-scales(k)/2:origy+maxpad+scales(k)/2,maxpad+1-scales(k)/2:origx+maxpad+scales(k)/2);
    full_mask = od_filter.(['mask',num2str(scales(k))]);
    for y = 1:16:768
        tb = y - scales(k)/2;
        bb = y + scales(k)/2-1;
        ymask = full_mask;
        if y < scales(k)/2
            ymask = full_mask(scales(k)/2+1-(y-1):end,:);
            tb = 1;
        end
        if y > origy - scales(k)/2
            ymask = full_mask(1:scales(k)-(y+scales(k)/2-origy)+1,:);
            bb = origy;
        end
        for x = 1:16:768
            lb = x - scales(k)/2;
            rb = x + scales(k)/2-1;
            mask = ymask;
            if x < scales(k)/2
                mask = ymask(:,scales(k)/2+1-(x-1):end);
                lb = 1;
            end
            if x > origx - scales(k)/2
                mask = ymask(:,1:scales(k)-(x+scales(k)/2-origx)+1);
                rb = origx;
            end        
            diff_img(y,x,k) = corr2(angle_map(tb:bb,lb:rb),mask);
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

