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

function GW=GaborWavelet(sigma,theta,lambda,psi,gamma)
 
sigma_x = sigma;
sigma_y = sigma/gamma;
 
% Bounding box
nstds = 3;
xmax = max(abs(nstds*sigma_x*cos(theta)),abs(nstds*sigma_y*sin(theta)));
xmax = ceil(max(1,xmax));
ymax = max(abs(nstds*sigma_x*sin(theta)),abs(nstds*sigma_y*cos(theta)));
ymax = ceil(max(1,ymax));
xmin = -xmax; ymin = -ymax;
[x,y] = meshgrid(xmin:xmax,ymin:ymax);
 
% Rotation 
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);
 
GW = 1/(2*pi*sigma_x *sigma_y) * exp(-.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);