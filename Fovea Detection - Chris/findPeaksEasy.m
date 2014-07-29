function [ Idx ] = findPeaksEasy(values, tol, threshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

diff = zeros(length(values),1);
count = 1;
for i = 2:length(values)
    diff(count) = values(i)-values(i-1);
    count = count +1;
end

%Return widest extrema greater than the threshold
Idx = find(abs(diff)<tol & values > threshold)
T = clusterdata(Idx, 20);
%get biggest cluster
max_sz = 0;
for i = 1:max(T)
    sz = sum(T==i);
    if sz > mx_sz;
        mx_sz = sz;
        biggest = T;
    end
end

%find midpoint of biggest cluster
Range = find(T==biggest);
Idx = round((max(Range)-min(Range)/2));