function p = twomodegauss(m1, sig1, m2, sig2, A1, A2, k)
%*******ADAPTED FROM GONZALEZ, WOODS "DIGITAL IMAGE PROCESSING IN MATLAB"
% FIFTH EDITION, 2009 - FUNCTION TWOMODEGAUSS ON PG 100***********
% P= TWOMODEGAUSS(M1, SIG1, M2, SIG2, A1, A2, K) generates a bimodal
% Gaussian-like function in the interval [0, 1].  P is a 256-element vector
% normalized so that SUM(P) equals 1.  The mean and standard deviation of
% the modes are (M1, SIG1) and (M2, SIG2), respectively.  A1 and A2 are the
% amplitude values of the two modes.  K is an offset value that raises the
% "floor" of the function.

c1 = A1*(1/((2*pi)^0.5)*sig1);
k1 = 2*(sig1^2);
c2 = A2*(1/((2*pi)^0.5)*sig2);
k2 = 2*(sig2^2);
z = linspace(0,1,256);
v
p = k+c1*exp(-((z-m1).^2)./k1) + c2*exp(-((z-m2).^2)./k2);
p = p./sum(p(:));

end