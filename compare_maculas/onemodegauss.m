function p = onemodegauss(m, sig, A, k)
% P= TWOMODEGAUSS(M, SIG, A, K) generates a
% Gaussian function in the interval [0, 1].  P is a 256-element vector
% normalized so that SUM(P) equals 1. The mean and standard deviation of
% the function is (M, SIG), A is the amplitude, and k is an offset that
% raises the "floor" of the function

c = A*(1/((2*pi)^.5)*sig);
r = 2*(sig^2);
z = linspace(0,1,256);
p = k+c*exp(-((z-m).^2)./r);
p = p./sum(p(:));

end
