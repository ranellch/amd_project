% manual rigid registration

Tx = 0;
Ty = 0;
theta = 0;
TxPtr = libpointer('doublePtr', Tx);
TyPtr = libpointer('doublePtr', Ty);
thetaPtr = libpointer('doublePtr', theta);
figure('KeyPressFcn',{@manualRegisterKeyPressFcn, img_late, img_early, TxPtr, TyPtr, thetaPtr});
colormap(gray);
imagesc(img_late);
axis equal
hold on
imagesc(img_early, 'AlphaData', .5);
hold off
maximize;

