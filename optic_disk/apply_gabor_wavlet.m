function [WaveletPieces] = apply_gabor_wavlet(img)
    addpath('GaborWavelet');
    
    %Convert image to double image
    img = double(img);

    lambda_wavelength = 8;
    sigma_stddev = 0.56 * lambda_wavelength;
    theta_orient = [0, pi/3.0, (2.0*pi) / 3.0, pi, (4.0 * pi) / 3.0, (5.0 * pi) / 3.0];
    phi_phase_offset = [0, 90];
    gamma_aspect_ratio = 0.5;
    bandwidth = 0;
    
    WaveletPieces = zeros(size(img, 1), size(img, 2), size(theta_orient, 2), size(phi_phase_offset, 2));
    current_piece = 1;
    
    for v=1:size(phi_phase_offset, 2);
        for u=1:size(theta_orient, 2);
            GW = gaborfilter(img, lambda_wavelength, sigma_stddev, theta_orient(u), phi_phase_offset(v), gamma_aspect_ratio, bandwidth);
            figure(current_piece), imshow(GW);
            
            %Keep this convolution in a matrix
            for y=1:size(img, 1)
                for x=1:size(img,2)
                    WaveletPieces(y, x, current_piece) = GW(y, x);
                end
            end
            
            disp(['Finished Orientation & Scale: ', num2str(current_piece)]);
            
            %Update the current piece
            current_piece = current_piece + 1;
        end
    end
end