function [rows] = reorganizeLayeredImgFeatures2RowFeatureVectors(stackMxs)
%[rows]=ORGANIZEMX2ROW(stackMxs)
%   converts a 3d matrix of [m¡Án¡Áp] to a 2d matrix of [(mn)¡Áp]

[m, n, p] = size(stackMxs);
rows = zeros(m*n, p);
for i = 1:p
   rows(:, i) = reshape(stackMxs(:,:,i), m*n, 1); 
end

end

