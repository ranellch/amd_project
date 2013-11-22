% function gb=GaborWavelet(sigma,theta,lambda,psi,gamma)
%  
% sigma_x = sigma;
% sigma_y = sigma/gamma;
%  
% % Bounding box
% nstds = 3;
% xmax = max(abs(nstds*sigma_x*cos(theta)),abs(nstds*sigma_y*sin(theta)));
% xmax = ceil(max(1,xmax));
% ymax = max(abs(nstds*sigma_x*sin(theta)),abs(nstds*sigma_y*cos(theta)));
% ymax = ceil(max(1,ymax));
% xmin = -xmax; ymin = -ymax;
% [x,y] = meshgrid(xmin:xmax,ymin:ymax);
%  
% % Rotation 
% x_theta=x*cos(theta)+y*sin(theta);
% y_theta=-x*sin(theta)+y*cos(theta);
%  
% gb= exp(-.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);


% function GW = GaborWavelet (R, C, Kmax, f, u, v, Delt2)
% % Create the Gabor Wavelet Filter
% % Author : Chai Zhi  
% % e-mail : zh_chai@yahoo.cn
% 
% k = ( Kmax / ( f ^ v ) ) * exp( i * u * pi / 8 );% Wave Vector
% 
% kn2 = ( abs( k ) ) ^ 2;
% 
% GW = zeros ( R , C );
% 
% for m = -R/2 + 1 : R/2
%     
%     for n = -C/2 + 1 : C/2
%         
%         GW(m+R/2,n+C/2) = ( kn2 / Delt2 ) * exp( -0.5 * kn2 * ( m ^ 2 + n ^ 2 ) / Delt2) * ( exp( i * ( real( k ) * m + imag ( k ) * n ) ) - exp ( -0.5 * Delt2 ) );
%     
%     end
% 
% end

% function GW=GaborWavelet(sigma,theta,lambda,psi,gamma)
%  
% sigma_x = sigma;
% sigma_y = sigma/gamma;
%  
% % Bounding box
% nstds = 3;
% xmax = max(abs(nstds*sigma_x*cos(theta)),abs(nstds*sigma_y*sin(theta)));
% xmax = ceil(max(1,xmax));
% ymax = max(abs(nstds*sigma_x*sin(theta)),abs(nstds*sigma_y*cos(theta)));
% ymax = ceil(max(1,ymax));
% xmin = -xmax; ymin = -ymax;
% [x,y] = meshgrid(xmin:xmax,ymin:ymax);
% 
% % Rotation 
% x_theta=x*cos(theta)+y*sin(theta);
% y_theta=-x*sin(theta)+y*cos(theta);
%  
% GW = 1/(2*pi*sigma_x *sigma_y) * exp(-.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);


% Generates 2D real and imaginary Morlet wavelet kernels
%
% MORLET WAVELET (according to Wikipedia, as of Aug 16 2012)
% The Morlet wavelet (or Gabor wavelet) is a wavelet
% composed of a complex exponential (carrier) multiplied by
% a Gaussian window (envelope).
% This wavelet is closely related to human perception,
% both hearing and vision.
%
% USAGE
% [mr,mi] = morlet(scale,orientation,npeaks);
%
% RETURNS
% mr: real part of kernel (in the range [-1,1])
% mi: imaginary part of kernel (in the range [-1,1])
%
% PARAMETERS
% scale: controls the size of the kernel
%        typical values: 1,2,...,20
% orientation: angle of rotation, in degrees
%        typical values: anything in the range [0,360)
% npeaks: rough number of significant peaks appearing in the kernel
%        typical values: 1,2,...,10
%
% EXAMPLE
% scale = 20;
% orientation = 45;
% npeaks = 3;
% 
% [mr,mi] = morlet(scale,orientation,npeaks);
% 
% mr = mr-min(min(mr));
% mr = mr/max(max(mr));
% imshow(mr)
% 
% mi = mi-min(min(mi));
% mi = mi/max(max(mi));
% figure
% imshow(mi)
%
% VERSION
% 1.01, Feb 26 2013
%
% AUTHOR
% Marcelo Cicconet, New York University
% marceloc.net
function [mr,mi] = GaborWavelet(scale,orientation,npeaks)

% controls width of gaussian window (default: scale)
sigma = scale;

% orientation (in radians)
theta = -(orientation-90)/360*2*pi;

% controls elongation in direction perpendicular to wave
gamma = 0.5;

% width and height of kernel
support = 2.5*sigma/gamma;

% wavelength (default: 4*sigma)
lambda = 1/npeaks*4*sigma;

% phase offset (in radians)
psi = 0;


xmin = -support;
xmax = -xmin;
ymin = xmin;
ymax = xmax;

xdomain = xmin:xmax;
ydomain = ymin:ymax;

[x,y] = meshgrid(xdomain,ydomain);

xprime = cos(theta)*x+sin(theta)*y;
yprime = -sin(theta)*x+cos(theta)*y;

expf = exp(-0.5/sigma^2*(xprime.^2+gamma^2*yprime.^2));

mr = expf.*cos(2*pi/lambda*xprime+psi);
mi = expf.*sin(2*pi/lambda*xprime+psi);

% mean = 0
mr = mr-sum(sum(mr))/numel(mr);
mi = mi-sum(sum(mi))/numel(mi);

% norm = 1
mr = mr./sqrt(sum(sum(mr.*mr)));
mi = mi./sqrt(sum(sum(mi.*mi)));