function [ ] = manualTranslationalRegisterKeyPressFcn(src, event, img_late, img_early, TxPtr, TyPtr, flagPtr)
%MANUALTRANSLATIONALREGISTERKEYPRESSFCN Summary of this function goes here
%   Detailed explanation goes here

if length(event.Modifier) == 1 && strcmp(event.Modifier{:},'alt') && ...
        strcmp(event.Key, 's')
    set(flagPtr, 'Value', 1);
    title('Results saved.')
    set(src, 'KeyPressFcn', []);
elseif any( strcmp(event.Key, {'uparrow', 'downarrow', 'leftarrow', 'rightarrow'}) )
    Tx = get(TxPtr, 'Value');
    Ty = get(TyPtr, 'Value');
    switch event.Key
        case 'downarrow'
            Ty = Ty + 4;
        case 'uparrow'
            Ty = Ty - 4;
        case 'rightarrow'
            Tx = Tx + 4;
        case 'leftarrow'
            Tx = Tx - 4;
    end
    set(TxPtr, 'Value', Tx);
    set(TyPtr, 'Value', Ty);
    
    imagesc(img_late);
    axis equal
    hold on
    imagesc(Tx, Ty, img_early, 'AlphaData', .5);
    hold off
end

end

