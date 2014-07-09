function [responsemap] = matchingfiltering(img, step, o, L)
%[responsemap] = MATCHINGFILTERING(img, step, o, L)
%   Detailed explanation goes here

K = matchingfilter(o, L);

% summation_kernel = ones(size(K));
% mu_mx = imfilter(img, summation_kernel/numel(K), 'symmetric');
% img = img - mu_mx;
% Xsqure_mx = img.^2;
% summation_mx = imfilter(Xsqure_mx, summation_kernel, 'symmetric');
% img = img ./ sqrt(summation_mx);

responsemapmx = imfilter(img, K, 'symmetric');

for theta = step:step:(180-step)
    K1 = imrotate(K, theta, 'bilinear');
    K1 = K1 - mean(K1(:)); % shift mean to 0
    factorsquare = sum(K1(:).^2);
    K1 = K1/sqrt(factorsquare);
    
    m = imfilter(img, K1, 'symmetric');
    responsemapmx = cat(3, responsemapmx, m);
end

responsemap = max(responsemapmx, [], 3);

end

