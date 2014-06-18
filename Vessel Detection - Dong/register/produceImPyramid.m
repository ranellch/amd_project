function [im_pyramid] = produceImPyramid(im, pyramid_level)
%QUADRATICREGISTER 此处显示有关此函数的摘要
%   此处显示详细说明

im_pyramid=cell(pyramid_level,1);
im_pyramid{pyramid_level} = im;
for i = pyramid_level-1 :-1: 1
    im_pyramid{i} = impyramid(im_pyramid{i+1}, 'reduce');
end

end

