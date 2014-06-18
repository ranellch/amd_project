function [ ] = manualRegisterKeyPressFcn(src, event, img_late, img_early, TxPtr, TyPtr, thetaPtr)
%MANUALREGISTERKEYPRESSFCN Summary of this function goes here
%   Detailed explanation goes here

if any( strcmp(event.Key, {'uparrow', 'downarrow', 'leftarrow', 'rightarrow'}) )
    Tx = get(TxPtr, 'Value');
    Ty = get(TyPtr, 'Value');
    theta = get(thetaPtr, 'Value');
    step = pi/360;

    switch event.Key
        case 'downarrow'
            if length(event.Modifier) == 1 &&...
                    strcmp(event.Modifier{:},'control')
                theta = theta + step;
            else
                Ty = Ty + 4;
            end
        case 'uparrow'
            if length(event.Modifier) == 1 &&...
                    strcmp(event.Modifier{:},'control')
                theta = theta - step;
            else
                Ty = Ty - 4;
            end
        case 'rightarrow'
            if length(event.Modifier) == 1 &&...
                    strcmp(event.Modifier{:},'control')
                theta = theta - step;
            else
                Tx = Tx + 4;
            end
        case 'leftarrow'
            if length(event.Modifier) == 1 &&...
                    strcmp(event.Modifier{:},'control')
                theta = theta + step;
            else
                Tx = Tx - 4;
            end
    end
    set(TxPtr, 'Value', Tx);
    set(TyPtr, 'Value', Ty);
    set(thetaPtr, 'Value', theta);
    
    T = [cos(theta) sin(theta) 0; 
        -sin(theta) cos(theta) 0; 
        Tx Ty 1];
    tform = maketform('affine', T);
    outbounds = findbounds(tform, [1 1; size(img_early,2) size(img_early,1)]);
    img_tform = imtransform(img_early, tform, 'XData', outbounds(1:2), ...
        'YData', outbounds(3:4));
    
    imagesc(img_late);
    axis equal
    hold on
%     imagesc(Tx, Ty, img_early, 'AlphaData', .5);
    imagesc(outbounds(1), outbounds(3), img_tform, 'AlphaData', .5);
    hold off
end

end

