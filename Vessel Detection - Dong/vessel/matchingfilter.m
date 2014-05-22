function [K] = matchingfilter(o, L)
%MATCHFILTER Summary of this function goes here
%   Detailed explanation goes here

x = -3*o : 3*o;
k = exp(-x.^2 /2 /o^2);
k = k - mean(k); % shift mean to 0
K = repmat(k, L, 1);

% equal max response to 1
factorsquare = sum(K(:).^2);
K = K/sqrt(factorsquare);

end

