function [movingReg, tformEstimate, Rfixed] = phaseRegister(img_early, img_late, disp_flag)
%[movingReg, tformEstimate, Rfixed] = PHASEREGISTER(img_early, img_late, disp_flag)
%   Detailed explanation goes here

% similarity registration
tformEstimate = imregcorr(img_early,img_late);
% shade correction is only helpful to Surf+RANSAC registration (by experiments)
% tformEstimate = imregSurfRANSAC(shadeCorrection(img_early),shadeCorrection(img_late));

Rfixed = imref2d(size(img_late));
[movingReg4View, Rregistered] = imwarp(img_early,tformEstimate);
if exist('disp_flag', 'var') && disp_flag
    figure
    warning('off', 'images:initSize:adjustingMag');
    imshowpair(img_late, Rfixed, movingReg4View, Rregistered, 'blend');
    warning('on', 'images:initSize:adjustingMag');
    maximize
end

movingReg = imwarp(img_early, tformEstimate, 'OutputView', Rfixed, ...
    'FillValues', max(img_early(:)));
movingReg = im2unitRange(movingReg);
if exist('disp_flag', 'var') && disp_flag
    figure
    warning('off', 'images:initSize:adjustingMag');
    imshowpair(img_late, movingReg, 'blend');
    warning('on', 'images:initSize:adjustingMag');
    maximize
end

% [optimizer, metric] = imregconfig('multimodal');
% movingRegistered = imregister(img_early, img_late, 'similarity', optimizer, ...
%     metric, 'InitialTransformation', tformEstimate);
% blended2 = imfuse(img_late, movingRegistered, 'blend');
% figure
% imshow(blended2);

end

