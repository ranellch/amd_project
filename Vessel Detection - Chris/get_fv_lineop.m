function [ fv_image ] = get_fv_lineop( img )
%Returns normalized 3D feature vector image

lineop_obj = [];
norien = 12;
count = 1;
strengths = [];
for length = [9, 15, 25]
    %Init the orthogonal line operator class
    lineop_obj{count} = line_operator(length, norien);
    %get max line strength for every pixel over all orientations of current scale
    [mx_str, mx_ang, square_avg] = lineop_obj{count}.get_strength_img(img);
    strengths = cat(3,strengths, mx_str);
    count = count+1;
end

%get maximums over all scales
[max_line_str, index] = max(strengths, [], 3);
%get ortho line strength for every pixel at max scale and orientation
ortho_str = zeros(size(img));
for y = size(img,1)
    for x = size(img,2)
        ortho_str(y,x) = lineop_obj{index(y,x)}.get_ortho_str(img, mx_ang(y,x), square_avg(y,x), y,x);
    end
end

fv_image = cat(3, zero_m_unit_std(max_line_str), zero_m_unit_std(ortho_str), zero_m_unit_std(img));

end

