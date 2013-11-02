function [WaveletPieces, Combined] = apply_gabor_wavlet(img)
    addpath('GaborWavelet');
    
    %Convert image to double image
    img = im2double(img);
    if(ndims(img) > 2)
        img = rgb2gray(img);
    end
            
    R = 127; C = 127;
    Kmax = pi / 2;
    f = sqrt(2);
    Delt = 2 * pi;
    Delt2 = Delt * Delt;
    v_max = 5;
    u_max = 8;
    [m,n] = size(img);
        
    %Calculate the padding on the original image
    pR = (R-1)/2;
    pC = (C-1)/2;
    if rem(m,2) ~= 0; pR = pR + 1; end;
    if rem(n,2) ~= 0; pC = pC + 1; end;
    img = padarray(img,[pR pC],'pre');
    
    %Build bank of filters
    GW = cell(v_max*u_max,R,C);
    cell_index = 1;
    for v=0:(v_max-1)
        for u=1:u_max
            GW{cell_index} = GaborWavelet(R, C, Kmax, f, u, v, Delt2);
            cell_index = cell_index + 1;
        end
    end
    disp(['Done Building Filter Bank! Count: ', num2str(size(GW, 1))]);

    %Calculate the padding required for Gabor Wavelets
    padsize = size(img) - [R C];
            
    %Precompute the fast foruier transform of the original image
    imgFFT = fft2(img);
  
    %Convolve all the filters with the image
    imgfilt = cell(v_max*u_max, size(img,1), size(img,2));
    cell_index = 1;
    for i=1:size(GW, 1)
        filter_pad = padarray(GW{i},  padsize / 2);
        filter = fft2( ifftshift( filter_pad ) ); %# See Numerical Recipes.
        imgfilt{cell_index} = ifft2( imgFFT .* filter ); %# Apply Convolution Theorem.
        cell_index = cell_index + 1;
    end
    disp(['Done Convolving All Filters With Image! Count: ', num2str(size(imgfilt, 1))]);        
            
    %Sum up all the transformations 
    imgS = zeros(m,n);
    WaveletPieces = zeros(m, n, u_max * v_max);
    for i=1:size(imgfilt, 1)
        imgS = imgS + imgfilt{i}(pR+1:end,pC+1:end); %# Just use the valid part.
        for y=pR+1:size(imgfilt,2)
            for x=pC+1:size(imgfilt,3)
                WaveletPieces(y,x,i) = real(imgfilt{i}(y,x));
            end
        end
    end
    
    Combined = real(abs(imgS));
end