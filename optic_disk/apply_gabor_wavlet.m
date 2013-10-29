function [WaveletPieces] = apply_gabor_wavlet(img)
    addpath('GaborWavelet');
    
    img = double(img);

    R = 128;
    C = 128;
    Kmax = pi / 2;
    f = sqrt( 2 );
    Delt = 2 * pi;
    Delt2 = Delt * Delt;

    v_max = 4;
    u_max = 7;
    
    WaveletPieces = zeros(size(img, 1), size(img, 2), v_max * u_max);
    current_piece = 1;
    
    for v = 0 : v_max - 1
        for u = 1 : u_max
            GW = GaborWavelet ( R, C, Kmax, f, u, v, Delt2 ); % Create the Gabor wavelets
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
    end
end