function [ fv_image, max_angles ] = get_fv_lineop( img )
%Returns normalized 3D feature vector image

lineop_obj = [];
norien = 12;
count = 1;
all_strengths = [];
all_ortho_strengths = [];
all_max_angles = [];
for length = [9, 15, 25]
    %Init the orthogonal line operator class
    lineop_obj{count} = line_operator(length, norien);
    %get max line strength for every pixel over all orientations of current scale
    [mx_str, ortho_str, mx_ang] = lineop_obj{count}.get_line_strengths(img);
    all_strengths = cat(3,all_strengths, mx_str);
    all_ortho_strengths = cat(3, all_ortho_strengths, ortho_str); 
    all_max_angles = cat(3,all_max_angles, mx_ang);
    count = count+1;
end

%get maximums over all scales
[fv_max, index] = max(all_strengths, [], 3);
%get ortho line strength for every pixel at max scale and orientation
fv_ortho = zeros(size(img));
max_angles = zeros(size(img));
for y = 1:size(img,1)
    for x = 1:size(img,2)
        max_angles(y,x) = all_max_angles(y,x,index(y,x));
        fv_ortho(y,x) = all_ortho_strengths(y,x,index(y,x));
    end
end

fv_image = cat(3, fv_max, fv_ortho, img);

end

