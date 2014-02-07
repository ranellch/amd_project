function [GaborTransforms] = apply_gabor_wavelet(I, debug)

    %Convert image to double image
    I = im2double(I);

    npeaks = 1;
    theta = [0 30 60 90 120 150];
    lambda = [1 2 4];

    %Get the size of the input image
    [m,n] = size(I);
    
    %Layer all the transformations 
    GaborTransforms = zeros(m, n, length(lambda) * length(theta));
    piece_count = 1;
        
    %Iterate over all gabor wavelets
    for i=1:length(theta)
        for j=1:length(lambda)

            %Build the gabor wavelet
            [wavelet, ~] = morlet(lambda(j), theta(i), npeaks);
            
            %Convolve the img with the gabor wavelet
            GaborTransforms(:,:,piece_count) = conv2(I, wavelet, 'same');
           
            
            if(debug == 1)
                figure(1)
                subplot(length(theta), length(lambda), piece_count)
                imshow(real(wavelet), [])
            
                figure(2)
                subplot(length(theta), length(lambda), piece_count)
                imshow(GaborTransforms(:,:,piece_count))

            end
            
            piece_count = piece_count + 1;
        end
    end
     
    if debug==1
        figure(3)
        imshow(mat2gray(sum(GaborTransforms,3)));
    end
    
end
