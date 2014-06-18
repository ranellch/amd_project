function [K,slack_vars] = learn_kernel(X,K0,C,r)

global config

tol = config.thresh;
gamma = config.gamma;
max_iters = config.max_iters;


[U,S] = svd(K0);
G0 = U(:,1:r)*sqrt(S(1:r,1:r));
[G,slack_vars] = logdet_learn_LRK_mex(C, X, G0, tol,gamma,max_iters,r);
K = G*G';

return;
end