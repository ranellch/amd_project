function [y,r,c] = max2(x)
%MAX2  Find maximum of 2-D array
%   [Y,R,C] = MAX2(X) returns the value, row and column of a maximal
%   element of X.

[colmxs, rs] = max(x,[],1);  % Need to specify first dim
[y, c] = max(colmxs);
r = rs(c);

end
