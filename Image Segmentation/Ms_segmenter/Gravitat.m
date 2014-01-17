function Gravit = Gravitat(Gray_image)
% finds out forces acting on pixels from other pixels
[Rows, Cols] = size(Gray_image);
Gray_image = double(Gray_image);

% creating the filter
Wind = 3;
for i=1:2*Wind-1
   for j=1:2*Wind-1
      Filter(i, j) = exp(-abs(Wind-i) - abs(Wind-j));
   end
end
Filter(Wind, Wind) = 0;

Gravit = zeros(size(Gray_image(Wind:Rows-Wind+1, Wind:Cols-Wind+1)));
for i=1:2*Wind-1
   for j=1:2*Wind-1
      Gravit = Gravit + Filter(i, j) * ...
         exp(-abs(Gray_image(Wind:Rows-Wind+1, Wind:Cols-Wind+1) - ...
         Gray_image(i:Rows-Wind+1+i-Wind, j:Cols-Wind+1+j-Wind)));
   end
end