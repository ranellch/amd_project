function [u] = multiscaleTV_flow(f, t, mu)
%[u] = MULTISCALETV_FLOW(f, t, mu)
%
%   Input: f  - the image to be smoothed
%          t  - number of iterations
%          mu - time step (.001 recommended for [0 1] gray-level image)
%   BIB:
%   Xu, Robert S., et al. "Myocardial segmentation in late-enhancement MR
%   images via registration and propagation of cine contours." Biomedical
%   Imaging (ISBI), 2013 IEEE 10th International Symposium on. IEEE, 2013.

u = f;
for i = 1:t
    u=NeumannBoundCond(u);
    [ux,uy]=gradient(u); 
    normDu=sqrt(ux.^2 + uy.^2 + 1e-10);
    Nx=ux./normDu;
    Ny=uy./normDu;
    div=curvature_central(Nx,Ny);
    deltaU = mu*div;
    
    u = u + deltaU;
end
u = im2unitRange(u);

end

function g = NeumannBoundCond(f)
% Make a function satisfy Neumann boundary condition
    [nrow,ncol] = size(f);
    g = f;
    g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);
    g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);
    g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);
end

function K = curvature_central(nx,ny)
    [nxx,~]=gradient(nx);
    [~,nyy]=gradient(ny);
    K=nxx+nyy;
end

