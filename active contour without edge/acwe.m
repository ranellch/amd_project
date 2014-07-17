function u = acwe(u0, FImg, timestep,...
                    mu, v, lambda1, lambda2, pc, ...
                    epsilon, numIter)
%Effect: gradient-descent method to optimize the CV model described in
%paper: "Active contour without edge".
%Inputs:
%u0: the initial level set function.
%Img: the input gray img.
%timestep: the descenting step each time(positive real number)
%mu: the length term of equation(9) in ref[1]
%v: the area term of eq(9)
%lambda1, lambda2: the data fitting term
%pc: the penalty coefficient(used to avoid reinitialization according to [2])
%epsilon: the parameter to avoid 0 denominator
%numIter: the number of iterations
%reference:
%[1]. Active contour without edge. chan etc
%[2]. Minimizaion of region-scalable fitting energy for image segmentation.
%     by Li chunming etc.
%Author: Su dongcai at 2012/1/12 Email: suntree4152@gmail.com, qq:272973536
u = u0;
c1 = [];
c2 = [];
DistImg1 = zeros(size(FImg,1),size(FImg,2));
DistImg2 = DistImg1;
for k1=1:numIter
    u=NeumannBoundCond(u);
    K=curvature_central(u);
    
    DrcU=(epsilon/pi)./(epsilon^2+u.^2);                %eq.(9), ref[2] the delta function
    Hu=0.5*(1+(2/pi)*atan(u./epsilon));                 %eq.(8)[2] the character function how large is 'epsilon'?
    %figure, hist(Hu(:), 100);
    th = .5;
    [inside_idx] = find(Hu < th); [outside_idx] = find(Hu >= th);
    for i = 1:size(FImg,3)    
        Flayer  =FImg(:,:,i);
        c1 = mean2(Flayer(inside_idx)); c2 = mean2(Flayer(outside_idx));
        DistImg1 = DistImg1 + (FImg(:,:,i) - c1).^2; DistImg2 = DistImg2 + (FImg(:,:,i) - c2).^2;
    end
    data_force = -DrcU.*(mu*K - v - lambda1/size(FImg,3)*DistImg1 + lambda2/size(FImg,3)*DistImg2);
    %introduce the distance regularation term:
    P=pc*(4*del2(u) - K);               %ref[2]
    u = u+timestep*(data_force+P);
end                 %

function g = NeumannBoundCond(f)
%Neumann boundary condition
%originally written by Li chunming
%http://www.mathworks.com/matlabcentral/fileexchange/12711-level-set-for-image-segmentation
[nrow, ncol] = size(f);
g = f;
g([1 nrow],[1 ncol]) = g([3 nrow-2],[3 ncol-2]);  
g([1 nrow],2:end-1) = g([3 nrow-2],2:end-1);          
g(2:end-1,[1 ncol]) = g(2:end-1,[3 ncol-2]);  

function k = curvature_central(u)
%compute curvature:
%originally written by Li chunming
%http://www.mathworks.com/matlabcentral/fileexchange/12711-level-set-for-im
%age-segmentation
[ux, uy] = gradient(u);
normDu = sqrt(ux.^2+uy.^2+1e-10);

Nx = ux./normDu; Ny = uy./normDu;
[nxx, junk] = gradient(Nx); [junk, nyy] = gradient(Ny);
k = nxx+nyy;                                          