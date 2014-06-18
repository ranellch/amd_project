function Display_Boundary (Boundary)

Max_x = max(Boundary(1, :));
Min_x = min(Boundary(1, :));
Max_y = max(Boundary(2, :));
Min_y = min(Boundary(2, :));

Mb = zeros(Max_x-Min_x+1, Max_y-Min_y+1);
Mb(sub2ind(size(Mb), Boundary(1, :)+1-Min_x, Boundary(2, :)+1-Min_y)) = 1;

figure; image(Mb*255); colormap(gray(256));
