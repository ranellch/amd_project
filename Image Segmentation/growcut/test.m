%-- Tests growcut.m

load test_data

subplot(2,2,1), imshow(img); title('Image');
subplot(2,2,2), imshow(labels,[]); title('Seeds');

[labels_out, strengths] = growcut(img,labels);
labels_out = medfilt2(labels_out,[9,9]);

subplot(2,2,3), imshow(img);
hold on;
contour(labels_out,[0 0],'g','linewidth',4);
contour(labels_out,[0 0],'k','linewidth',2);
hold off;
title('Output');

subplot(2,2,4), imshow(labels_out);
title('Binary Output');
