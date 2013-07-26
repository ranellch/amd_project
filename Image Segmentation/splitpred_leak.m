function [ flag ] = splitpred_leak( region, f )
%SPLITPRED_LEAK Contains the predicate used to determine whether to split
%or merge regions during quad tree decomposition involving leakage in FA images.
%   FLAG = SPLIT_PREDICATE(REGION) sets flag to true if the pixels in
%   REGION have a mean intensity greater 150

M=mean2(f);
t = M+2*std2(f(:));
m = mean2(region);
flag = m > t;


end

