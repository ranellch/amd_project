function [ Idx ] = findMaxPeakEasy(values, tol)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

diff = zeros(length(values),1);
diff(1) = NaN;
for i = 2:length(values)
    diff(i) = values(i)-values(i-1);
end

%Return highest peak
Idx = find(abs(diff)<tol);
if isempty(Idx) || length(Idx) == 1
    return
else
    T = clusterdata([Idx,values(Idx)], 'criterion','inconsistent','cutoff',1);
    mx = 0;
    highest = 0;
    for i = 1:max(T)
        av = mean(values(Idx(T==i)));
        if av > mx;
        	mx = av;
            highest = i;
        end
    end
end
    

    %find midpoint of highest peak area
    Range = find(T==highest);
    Idx = round((max(Idx(Range))+min(Idx(Range)))/2);
end