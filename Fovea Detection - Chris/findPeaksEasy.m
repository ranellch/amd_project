function [ Idx ] = findPeaksEasy(values, threshold1, threshold2,delta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

diff = zeros(length(values)-delta*2,1);
count = 1;
for i = delta+1:length(values)-delta
    diff(count) = values(i) - (values(i-delta)+values(i+delta))/2;
    count = count +1;
end
figure, plot(values)
figure, plot(diff)
Idx = find(diff>threshold1 & values(delta+1:end-delta)>threshold2);
sortingmatrix = [Idx,diff(Idx)];
sortingmatrix = sortrows(sortingmatrix,-2);
Idx = sortingmatrix(:,1)+delta;

