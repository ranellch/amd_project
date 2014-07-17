function [bwimg] = process_labeled(inimg)
    bwimg = zeros(size(inimg, 1), size(inimg, 2));

    if(size(inimg, 3) < 3)
        error('Input label image must be a RGB image with a red area of highlighted non perfusion');
    end
    
    for y=1:size(inimg,2)
        for x=1:size(inimg,1);
            if(inimg(y,x,1) >= 250 && inimg(y,x,2) <= 20 && inimg(y,x,3) <= 10)
                bwimg(y,x) = 1;
            end
        end
    end
    
    bwimg = im2bw(bwimg);
    bwimg = imfill(bwimg, 'holes');  
end