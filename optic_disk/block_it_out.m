function [xval, xsize, yval, ysize] = block_it_out(img, blocks)
    xax = size(img, 2);
    yax = size(img, 1);
    
    xsize = round(xax / blocks) - 1;
    ysize = round(yax / blocks) - 1;
    
    total_blocks = blocks * blocks;
    xval = zeros(total_blocks, 1);
    yval = zeros(total_blocks, 1);
    
    index = 1;
    for x=0:blocks-1
        for y=0:blocks-1
            xval(index) = (xsize * x) + 1;
            yval(index) = (ysize * y) + 1;
            index = index + 1;
        end
    end
end