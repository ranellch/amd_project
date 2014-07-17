function [finalLabeling endoMask epiMask myoMask] = prepareAndCutOneSlice(imSA, endo, epi, PS, dispOpt)
%PREPAREANDCUTONESLICE Summary of this function goes here
%   Detailed explanation goes here

endoMask = roipoly(imSA, endo(:,1), endo(:,2));
epiMask = roipoly(imSA, epi(:,1), epi(:,2));
myoMask = epiMask & (~endoMask);

im = imSA .* myoMask;
try
    [t alpha_R sigma_R shift_R alpha_G sigma_G mu binSize] = RicianFit(imSA(epiMask), false);
    
    labeling = im>t;
    
    L0Cost = alpha_R .* (im+shift_R) ./sigma_R^2 .* exp( -(im+shift_R).^2 ./ 2 ./ sigma_R^2 );
    L0Cost = -log(L0Cost+eps);
    L0Cost( im<=(sigma_R-shift_R) ) = 0;
    
    L1Cost = alpha_G / sqrt(2*pi) / sigma_G .* exp( -.5 .* (   (im-mu) ./ sigma_G   ).^2 );
    L1Cost = -log(L1Cost+eps);
    L1Cost( im>=mu ) = 0;
    
    sigma = mu - (sigma_R - shift_R);
    hCost = exp( - diff(im, 1, 2).^2 ./ 2 ./ sigma^2 );
    hCost = padarray(hCost, [0 1], max(hCost(:)), 'post');
    
    vCost = exp( - diff(im).^2 ./ 2 ./ sigma^2 ) / PS(1);
    vCost = padarray(vCost, [1 0], max(vCost(:)), 'post');
    
    save('.\scarSegment\classifyGraphCut\IM.mat', ...
        'labeling', 'L0Cost', 'L1Cost', 'hCost', 'vCost');
    iterNum = 2;
    call2dCutExecutable;
    load('.\scarSegment\classifyGraphCut\IM.mat', 'optimizedLabeling');
catch
    t = graythresh(imSA(epiMask));
    optimizedLabeling = im>t;
end

if any(optimizedLabeling(:))
    filteredLabeling = connComponentFilter2d(optimizedLabeling, epiMask, endoMask);
    grownLabeling = MRMregionGrow(filteredLabeling, im.*myoMask, myoMask);
    finalLabeling = MVOfilling(grownLabeling, endoMask, myoMask);
else
    finalLabeling = optimizedLabeling;
end

if dispOpt
%     displayLabeling2D(imSA, endo, epi, optimizedLabeling, [1 0 0]);
    
    if exist('filteredLabeling', 'var')
        displayLabeling2D(imSA, endo, epi, ...
            filteredLabeling, [1 0 0], filledLabeling&(~filteredLabeling), [0 1 0], ...
            finalLabeling&(~filledLabeling), [1 1 0]);
    else
        displayLabeling2D(imSA, endo, epi, finalLabeling, [1 0 0]);
    end
    maximize all;
end

end

