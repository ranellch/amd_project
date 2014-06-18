function [t] = quadraticRegister(img_early, img_late, Tx, Ty)
%QUADRATICREGISTER Summary of this function goes here
%   Detailed explanation goes here

t = zeros(2,6);
t(1,4) = 1;
t(2,5) = 1;
if exist('Tx', 'var') && exist('Ty', 'var')
    t(1,6) = -Tx;
    t(2,6) = -Ty;
end

x0 = t(:);
optim=struct('display', 'iter', 'Algorithm', 'interior-point', ...
        'FinDiffType', 'central', 'DiffMinChange', 1, 'TolX',eps, 'TolFun',eps, ...
        'MaxFunEvals', 3000);
x = fminunc(@(x)disimilarityMeasure(x,img_early,img_late), x0, optim);

t(1,:) = x(1:2:end);
t(2,:) = x(2:2:end);

end

function measuring = disimilarityMeasure(x,img_early,img_late)
t(1,:) = x(1:2:end);
t(2,:) = x(2:2:end);

img_moving = quadraticTform(img_early, t);

measuring = image_difference(img_moving, img_late, 'sd');

end

function img_moving = quadraticTform(img_early, t)
[X, Y] = meshgrid(1:size(img_early,2), 1:size(img_early,1));

X_prime = t(1,1)*X.^2 + t(1,2)*X.*Y + t(1,3)*Y.^2 + t(1,4)*X + t(1,5)*Y + t(1,6);
Y_prime = t(2,1)*X.^2 + t(2,2)*X.*Y + t(2,3)*Y.^2 + t(2,4)*X + t(2,5)*Y + t(2,6);

img_moving = interp2(img_early, X_prime, Y_prime, 'linear', 0);
end

