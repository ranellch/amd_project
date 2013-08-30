function [out] = vessel_detection_curvlet(I)
    addpath('../curvlet/fdct_wrapping_matlab/');
    
    if length(size(I)) > 2
        I = rgb2gray(I);
    end
    
    I = double(I);

    K = 1;
    a = 4;
    p = 0;
    q = 0;
        
    for i=1:11
        p = 0;
        for f=1:11
            %Calculate the Curvlet coefficients
            C = fdct_wrapping(I, 0);
            
            %Get a zeroed out version of the Coefficients matrix
            ctemp = C;
            for j=1:length(ctemp)
                for l=1:length(ctemp{j})
                    for y=1:size(ctemp{j}{l}, 1)
                        for x=1:size(ctemp{j}{l}, 2)
                           ctemp{j}{l}(y, x) = 0;                         
                        end
                    end
                end
            end

            %Modify the Curvlet coefficients using the reserach paper described in
            %the function in the comments
            C = modify_coefficients(C, ctemp, K, a, p, q);

            %Rebuild the image using the modified coefficient values
            Y = mat2gray(real(ifdct_wrapping(C, 0)));
            imwrite(Y, ['TestDir/ppoint', num2str(f-1),'qpoint', num2str(i-1), '.jpg'], 'jpg');
            
            p = p + .1;
            disp('----------------------------------------------------------');
        end
        q = q + .1;
    end
    
    return;
    
    %Get a 5x5 structuring elements that are a line with 22.5 degrees of resolution
    zeroline = [0,0,0,0,0;...
                0,0,0,0,0;...
                1,1,1,1,1;...
                0,0,0,0,0;...
                0,0,0,0,0;];
    twentytwopointfive = [0,0,0,0,0;...
                          0,0,0,0,1;...
                          0,0,1,0,0;...
                          1,0,0,0,0;...
                          0,0,0,0,0;];
    fortyfive = [0,0,0,0,1;...
                 0,0,0,1,0;...
                 0,0,1,0,0;...
                 0,1,0,0,0;...
                 1,0,0,0,0;];
    sixtysevenpointfive = [0,0,0,1,0;...
                           0,0,0,0,0;...
                           0,0,1,0,0;...
                           0,0,0,0,0;...
                           0,1,0,0,0;];
    vertline = [0,0,1,0,0;...
                0,0,1,0,0;...
                0,0,1,0,0;...
                0,0,1,0,0;...
                0,0,1,0,0;];
     
    %Combine all the images into a final image using each structuring element
    height = size(I,1);
    width = size(I,2);
    final_img = zeros(height, width);
    
    M = 8;
    final_img = add_img(apply_morph(Y, zeroline), M, final_img);
    final_img = add_img(apply_morph(Y, twentytwopointfive), M, final_img);
    final_img = add_img(apply_morph(Y, fliplr(twentytwopointfive)), M, final_img);
    final_img = add_img(apply_morph(Y, fortyfive), M, final_img);
    final_img = add_img(apply_morph(Y, fliplr(fortyfive)), M, final_img);
    final_img = add_img(apply_morph(Y, sixtysevenpointfive), M, final_img);
    final_img = add_img(apply_morph(Y, fliplr(sixtysevenpointfive)), M, final_img);
    final_img = add_img(apply_morph(Y, vertline), M, final_img);
    
    figure(11);
    imshow(final_img);
    
    figure(2);
    subplot(1,2,1); colormap gray; imagesc(real(I)); axis('image'); title('original image');
    subplot(1,2,2); colormap gray; imagesc(real(Y)); axis('image'); title('partial reconstruction');
end

function [newCoeff] = modify_coefficients(C, ctemp, K, a, p, q)
    newCoeff = C;
          
    %Loop through each scale|angle
    disp(['A total of: ', num2str(length(C)), ' scale(s) to run!']);
    for j=1:length(C)
        for l=1:length(C{j})
            %Set the empty coefficient array to current scale|angle
            for y=1:size(C{j}{l}, 1)
                for x=1:size(C{j}{l}, 2)
                    ctemp{j}{l}(y, x) = C{j}{l}(y, x);
                end
            end

            %Rebuild the image using only one angle and scale at a time
            ctempimg = real(ifdct_wrapping(ctemp, 0));

            %Reset the coefficient array to empty
            for y=1:size(C{j}{l}, 1)
                for x=1:size(C{j}{l}, 2)
                    ctemp{j}{l}(y, x) = 0;
                end
            end
            
            %Estimate the noise image standard deviation for this sub-band
            sigma = img_stddev(ctempimg);
            
            %Find the maximum value within this scale and angle
            Mij = max(C{j}{l}(:));

            %calculate the m value for the peacewise function shown in equation(7)
            m = K * (Mij - sigma);
            
            %Apply the yalpha function to each coefficient in this scale and angle wedge
            newCoeff{j}{l} = process_subband_matrix(C{j}{l}, sigma, m, a, p, q);
        end
    end
end

function [sigma] = img_stddev(img)
    %This method was developed using the following paper
    % WAVELET IMAGE DE-NOISING METHOD BASED ON NOISE STANDARD DEVIATION ESTIMATION
    
    %Define the noise estimation template as the difference between two
    %LaPlace templates
    M = [ 1,-2, 1;
         -2, 4,-2;
          1,-2, 1];
      
    %Convolve the noise estimation matrix with the image
    convolve = conv2(img, M);
    
    %Get the sum of the absolutue value of the matrix from the convolution
    convoluve_abs = abs(convolve);
    summation = sum(convoluve_abs(:));
    
    %k and l is the image height and image width
    k = size(img, 2);
    l = size(img, 1);
    
    %Calculate the standard deviation from the main 
    sigma = sqrt(pi / 2) * (1 / (6 * (k - 2) * (l - 2))) * summation;
end

function [result] = process_subband_matrix(CoeffMatrix, sigma, m, a, p, q)
    %For each sub matrix find the maximum value and use it to calculate
    %variable m (lowercase), this is based upon the following paper.
    %Fast and automatic algorithm for optic disc extraction in
    %   retinal images using principle-component-analysis-based
    %   preprocessing and curvelet transform
    
    %Loop on each value within the CoeffMatrix and apply the yalpha function
    %the yalpha function returns a multiplication value
    for y=1:size(CoeffMatrix, 1)
        for x=1:size(CoeffMatrix, 2)
            CoeffValue = CoeffMatrix(y, x);
            modify_coeff = yalpha(abs(CoeffValue), sigma, m, a, p, q);
            CoeffMatrix(y, x) = CoeffValue * modify_coeff;
        end
    end
    
    %set output variable to the results from the modified matrix
    result = CoeffMatrix;
end

function [result] = yalpha(x, sigma, m, a, p, q)
    %These three variables must be tuned to gain desierable results
    K1 = 1;
    K2 = 1;
    
    %c is equal to the standard deviation of the image
    c = sigma;
    
    if (abs(x) < (a*c))
        result = 1;
    elseif ((a*c) <= abs(x) && abs(x) < (2*a*c))
        result = ((abs(x) - (a*c) / (a*c)) * ((m / (a*c))^p)) + (((2*a*c) - abs(x)) / (a*c));
    elseif ((2*a*c) <= abs(x) && abs(x) < m)
        result = K1 * ((m / abs(x))^p);
    elseif (m <= abs(x))
        result = K2 * ((m / abs(x))^q);
    else
        disp('Error in yalpha');
    end
end

function [finalimg] = add_img(inputimg, M, finalimg)
    if size(inputimg, 1) == size(finalimg, 1) && ...
       size(inputimg, 2) == size(finalimg, 2)
        for y=1:size(inputimg, 1)
            for x=1:size(inputimg, 2)
                finalimg(y, x) = finalimg(y, x) + (inputimg(y, x) / M);
            end
        end
    else
        disp('Incorrect SIZE');
    end
end

function [out] = apply_morph(img, strelement)
    newimg = imclose(img, strelement);
    newimg = imopen(newimg, strelement);
    
    newimg1 = imdilate(newimg, strelement);
    newimg2 = imerode(newimg, strelement);
    
    out = imsubtract(newimg1, newimg2);
end

