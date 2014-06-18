function [BWout] = vessel_detection(I)

    height = size(I,1);
    width = size(I,2);

    %Run Gaussian filter
    Ifilt = imfilter(I, fspecial('gaussian', [5 5], 1.2), 'symmetric');

    %Bottom Hat Filter   
    se = strel('square', round(width/50));
    Ibot = imbothat(Ifilt, se);
    
    %Threshold this badboy
    threshold = graythresh(Ibot);
    BWout = im2bw(Ibot, threshold*.75);
    
    %Get the skeleton of the image      
    BWout = bwareaopen(BWout, 500); 
    BWout = imclose(BWout, strel('disk', round(width/500)));
    BWout = bwmorph(BWout, 'skel', Inf);
    BWout = bwmorph(BWout, 'bridge');
    BWout = bwmorph(BWout, 'spur', 20);
    BWout = bwmorph(BWout, 'clean');
    BWout = bwareaopen(BWout, 100);

    

   
end


