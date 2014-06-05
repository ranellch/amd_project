function [circularity] = get_circularity(img)
    img = im2bw(img);
    
    Areas  = regionprops(img, 'Area');
    Perimeters = regionsprops(img, 'Perimeter');
    
    if size(Areas,1) ~= size(Perimeters, 1)
        circularity = zeros(1);
        return;
    end
    
    circularity = zeros(1, size(Areas, 1));
    for i=1:size(Areas,1)
        Area = Areas(i,1).Area;
        Perimeter = Perimeters(i,1).Perimeter;
        
        circularity(1,i) = (Perimeter .^ 2) ./ (4 * pi * Area);
    end
end