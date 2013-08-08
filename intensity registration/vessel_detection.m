function [BWout] = vessel_detection(I)

    height = size(I,1);
    width = size(I,2);

    %Run Gaussian filter
    Ifilt = imfilter(I, fspecial('gaussian', [5 5], 1.2), 'same');
    
    %Close that shit
    Iclose = imclose(Ifilt, strel('square', round(width/500)));

    %Bottom Hat Filter   
    se = strel('square', round(width/50));
    Ibot = imbothat(Iclose, se);
    figure, imshow(Ibot)
   
    %Threshold this badboy
    threshold = graythresh(Ibot);
    BWout = im2bw(Ibot, threshold*.9);
    figure, imshow(BWout)
    
    %Get the skeleton of the image      
    BWout = bwareaopen(BWout, 500); 
    BWout = bwmorph(BWout, 'dilate');
    figure, imshow(BWout)
    BWout = bwmorph(BWout, 'skel', Inf);
    BWout = bwmorph(BWout, 'bridge');
    BWout = bwmorph(BWout, 'spur', 20);
    BWout = bwmorph(BWout, 'clean');
    BWout = bwareaopen(BWout, 200);
    
    figure, imshow(BWout)
    

end


