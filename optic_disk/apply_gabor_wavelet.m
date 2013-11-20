function [WaveletPieces] = apply_gabor_wavelet(img, debug)
    addpath('GaborWavelet');
    
    %Convert image to double image
    img = im2double(img);
    if(ndims(img) > 2)
        img = rgb2gray(img);
    end

    npeaks = 1;
    theta = [0 20 40 60 80 100 120 140 160];
    lambda = [1 2 3];

    %Get the size of the input image
    [m,n] = size(img);
    
    %Sum up all the transformations 
    WaveletPieces = zeros(m, n, size(theta, 2) * size(lambda, 2));
    piece_count = 1;
        
    %Iterate over all gabor wavelets
    for v=1:size(theta, 2)
        t = theta(1,v);
        for u=1:size(lambda, 2)
            l = lambda(1, u);

            %Build the gabor wavelet
            [GW, ~] = GaborWavelet(l, t, npeaks);
            
            %Convolve the img with the gabor wavelet
            convolved_img = conv2(img, GW, 'same');
            
            %Save the convolution to the output matrix
            for y=1:size(WaveletPieces, 1)
                for x=1:size(WaveletPieces, 2)
                    WaveletPieces(y,x,piece_count) = convolved_img(y,x);
                end
            end
            
            if(debug == 1)
                figure(1);
                subplot(size(theta,2), size(lambda,2), piece_count);
                imshow(real(GW), []);
            
                figure(2);
                subplot(size(theta,2), size(lambda,2), piece_count);
                imshow(convolved_img);
            end
            
            piece_count = piece_count + 1;
        end
    end
end
