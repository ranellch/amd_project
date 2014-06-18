function [Tx, Ty] = manualTranslationRegister(img_early, img_late)
%MANUALTRANSLATIONREGISTER Summary of this function goes here
%   Detailed explanation goes here

Tx = 0;
Ty = 0;
stop_flag = uint8(0);
TxPtr = libpointer('doublePtr', Tx);
TyPtr = libpointer('doublePtr', Ty);
flagPtr = libpointer('uint8Ptr', stop_flag);
figure('KeyPressFcn',{@manualTranslationalRegisterKeyPressFcn, ...
    img_late, img_early, TxPtr, TyPtr, flagPtr});
colormap(gray);
imagesc(img_late);
axis equal
hold on
imagesc(img_early, 'AlphaData', .5);
hold off

while ~stop_flag
    pause(1);
    stop_flag = get(flagPtr, 'Value');
end

Tx = get(TxPtr, 'Value');
Ty = get(TyPtr, 'Value');

end

