function Place_images (Dimension, Images)
% creates a new window that contains all the specified existing windows/images
% along with possible lines and other graphics, but without menus
% Dimension is in the form [x, y] and Images is an array of their numbers

figure;
for i=1:size(Images, 1)
	subplot(Dimension(1), Dimension(2), i);
	image_children = get(Images[i], 'Children');
	
