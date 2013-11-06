function [WaveletPieces, Combined] = apply_gabor_wavelet(img)
    addpath('GaborWavelet');
    
    %Convert image to double image
    img = im2double(img);
    if(ndims(img) > 2)
        img = rgb2gray(img);
    end

    %Get the parameters for the gabor wavelet            
%     R = 127; C = 127;
%     Kmax = pi / 2;
%     f = sqrt(2);
%     Delt = 2 * pi;
%     Delt2 = Delt * Delt;
%     v_max = 5;
%     u_max = 8;

    sigma = 0.1;
    theta = [30 45 60 120];
    lambda = [5 7 11 13];
    psi = 0.2;
    gamma = 0.1;
    

    %Get the size of the input image
    [m,n] = size(img);
        
    %Calculate the padding on the original image
%     pR = (R-1)/2;
%     pC = (C-1)/2;
%     if rem(m,2) ~= 0; pR = pR + 1; end;
%     if rem(n,2) ~= 0; pC = pC + 1; end;
%     img = padarray(img,[pR pC],'pre');
    
    figure(100);
        
    
    %Build bank of filters
    GW = cell(v_max*u_max,R,C);
    cell_index = 1;
    for v=1:size(theta, 1)
        for u=1:size(lambda, 1)
            GW{cell_index} = GaborWavelet(sigma, theta, lambda(u), psi(v), gamma);
            
            subplot(v_max, u_max, cell_index);
            imshow(real(GW{cell_index}), []);
            
            cell_index = cell_index + 1;
        end
    end
    disp(['Done Building Filter Bank! Count: ', num2str(size(GW, 1))]);

    %Calculate the padding required for Gabor Wavelets
    padsize = (size(img) - [R C]) / 2;
            
    %Precompute the fast foruier transform of the original image
    imgFFT = fft2(img);
  
    %Convolve all the filters with the image
    imgfilt = cell(v_max*u_max, size(img,1), size(img,2));
    cell_index = 1;
    for i=1:size(GW, 1)
%         filter_pad = padarray(GW{i},  padsize);
%         filter = fft2( ifftshift( filter_pad ) ); %# See Numerical Recipes.
%         imgfilt{cell_index} = ifft2( imgFFT .* filter ); %# Apply Convolution Theorem.
        imgfilt{cell_index} = conv2(img);
        cell_index = cell_index+1;
    end
    disp(['Done Convolving All Filters With Image! Count: ', num2str(size(imgfilt, 1))]);        
            
    %Sum up all the transformations 
    imgS = zeros(m,n);
    WaveletPieces = zeros(m, n, u_max * v_max);
    
    for i=1:size(imgfilt, 1)
        imgS = imgS + imgfilt{i}(pR+1:end,pC+1:end); %# Just use the valid part.
        yval=0;
        for y=pR+1:size(imgfilt,2)
            yval=yval+1;
            xval=0;
            for x=pC+1:size(imgfilt,3)
                xval=xval+1;
                WaveletPieces(yval,xval,i) = real(imgfilt{i}(y,x));
            end
        end
    end
    
    disp('Done building the WaveletPieces return value!');
    
    Combined = real(abs(imgS));
end
