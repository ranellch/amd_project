function [ Idx ] = findPeaksEasy(values, tol, threshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

diff = zeros(length(values),1);
diff(1) = NaN;
diff2 = diff;
for i = 2:length(values)
    diff(i) = values(i)-values(i-1);
end
for i = 2:length(values)
    diff2(i) = diff(i)-diff(i-1);
end
figure, plot(diff)
figure, plot(diff2)
%Return widest extrema greater than the threshold
Idx = find(abs(diff)<tol & values > threshold);
if isempty(Idx) || length(Idx) == 1
    return
else
    T = clusterdata([Idx,values(Idx)], 'criterion','inconsistent','cutoff',1);
    %get biggest cluster
    max_sz = 0;
    biggest = 0;
    for i = 1:max(T)
        sz = sum(T==i);
        if sz > max_sz;
            %make sure its a peak
            Range = (min(Idx(T==i))-1):(max(Idx(T==i))+1);
            if Range(end) > length(diff2), Range = Range(1:end-1); end
            if mean(diff2(Range)) < 0 
                max_sz = sz;
                biggest = i;
            end
        end
    end
    if biggest == 0
        Idx = [];
        return
    end

    %find midpoint of biggest cluster
    Range = find(T==biggest);
    Idx = round((max(Idx(Range))+min(Idx(Range)))/2);
end