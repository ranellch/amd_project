function [imgout] = get_fv_gabor(imgin)
    %Run the gabor stuff
    [sizey, sizex] = size(imgin);
    bigimg = padarray(imgin, [50 50], 'symmetric');
    fimg = fft2(bigimg);
    k0x = 0;
    k0y = 3;
    epsilon = 8;
    step = 10;
    gabor_image_temp = [];
    for a = [2 4 6 8]
        trans = maxmorlet(fimg, a, epsilon, [k0x k0y], step);
        trans = trans(51:(50+sizey), (51:50+sizex));
        gabor_image_temp = cat(3, gabor_image_temp, trans);
    end
    
    imgout = gabor_image_temp;
end