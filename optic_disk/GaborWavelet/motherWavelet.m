function res = motherWavelet(x,y,param,phase)

phai = param.phai;
kai  = sqrt(2*log(2)) * (2^phai+1) / (2^phai-1);
aspectRatio = param.aspectRatio;

if phase == 0     % even(cos)
    tmpRes = 1/sqrt(2) * exp(-1/(2*aspectRatio^2) * (aspectRatio^2*x.^2 + y.^2)) ...
        .* (exp(1i*kai*x) - exp(-kai^2/2));
    res = real(tmpRes);
elseif phase == 1 % odd(sin)
    tmpRes = 1/sqrt(2) * exp(-1/(2*aspectRatio^2) * (aspectRatio^2*x.^2 + y.^2)) ...
        .* exp(1i*kai*x);
    res = imag(tmpRes);
end