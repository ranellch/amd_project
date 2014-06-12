function [ candidate_region ] = choose_od( od_img, vessels, angles )
% Finds optic disk region of interest

addpath('..');
addpath('../Skeleton');

%Get vessels and angles of greatest lineop strength
vskel = bwmorph(skeleton(vessels) > 35, 'skel', Inf);
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
%  figure, imshow(mat2gray(angle_map))

%Run correlation on this mofo
od_img = labelmatrix(bwconncomp(od_img));
od_filter = load('od_masks', 'mask200', 'mask300', 'mask400');

disp('Running correlation')
e = cputime;
scales = [200 300 400];
diff_img = zeros(origy, origx,length(scales));
for k = 1:length(scales)
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
            %check if in texture of interest
            if od_img(y,x) > 0
                diff_img(y,x,k) = corr2(angle_map(tb:bb,lb:rb),mask);
            end
        end
    end
end
t = (cputime-e)/60.0;
disp(['Time to run correlation: ' num2str(t)])

%Only keep region containing max correlation
diff_img = max(diff_img,[],3);
[max_y, max_x, ~] = find(diff_img==max(diff_img(:)));
candidate_region = od_img == od_img(max_y,max_x);

end

