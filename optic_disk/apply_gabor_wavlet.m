function [WaveletPieces] = apply_gabor_wavlet(img)
    addpath('GaborWavelet');
    
    img = double(img);

    scales = 0.5;
    orientations = [0, pi/3.0, (2.0*pi) / 3.0, pi, (4.0 * pi) / 3.0, (5.0 * pi) / 3.0];
    psi = 90.0;
    lambda = 8.0;
    
    WaveletPieces = zeros(size(img, 1), size(img, 2), size(orientations, 2));
    current_piece = 1;
    
    %for v = 0 : size(scales);
        for u = 1 : size(orientations, 2);
            GW = GaborWavelet (0.56 * lambda, orientations(u), lambda, psi, scales); % Create the Gabor wavelets
            orien_scale = conv2(img, GW); %Convolve the gabor wavelet with the img
            
            %Keep this convolution in a matrix
            for y=1:size(img, 1)
                for x=1:size(img,2)
                    WaveletPieces(y, x, current_piece) = orien_scale(y, x);
                end
            end
            
            disp(['Finished Orientation & Scale: ', num2str(current_piece)]);
            
            %Update the current piece
            current_piece = current_piece + 1;
        end
    %end
end