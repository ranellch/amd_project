function [out] = vessel_detection_curvlet(I)
    pctg = 0.1;
    
    if length(size(I)) > 2
        I = rgb2gray(I);
    end
    
    height = size(I,1);
    width = size(I,2);
    
    C = fdct_wrapping(double(I), 0);
    
    % Get threshold value
    cfs =[];
    for s=1:length(C)
      for w=1:length(C{s})
        cfs = [cfs; abs(C{s}{w}(:))];
      end
    end
    cfs = sort(cfs); cfs = cfs(end:-1:1);
    nb = round(pctg*length(cfs));
    cutoff = cfs(nb);
    
    % Set small coefficients to zero
    for s=1:length(C)
        for w=1:length(C{s})
            C{s}{w} = C{s}{w} .* (abs(C{s}{w}) > cutoff);
        end
    end
    
    C = modify_coefficients(C, I);
    
    %Rebuild the image using the modified coefficient values
    Y = real(ifdct_wrapping(C));
    
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
    
    figure(1);
    imshow(final_img);
    
    figure(2);
    subplot(1,2,1); colormap gray; imagesc(real(I)); axis('image'); title('original image');
    subplot(1,2,2); colormap gray; imagesc(real(Y)); axis('image'); title('partial reconstruction');
end

function [newCoeff] = modify_coefficients(C, img)
    %Estimate the noise image standard deviation
    sigma = img_stddev(img);
    
    %Loop through each sub-band
    number_of_bands = length(C);
    for j=1:number_of_bands
        %Each sub-band can have one or more matricies of coefficients
        number_of_coefficients = length(C{1, j});
        for k=1:number_of_coefficients
        	CoeffMatrix = C{1, j}{1, k};
            process_subband_matrix(CoeffMatrix, sigma);
        end
    end
end

function [sigma] = img_stddev(img)
    %This method was developed using the following paper
    % WAVELET IMAGE DE-NOISING METHOD BASED ON NOISE STANDARD DEVIATION ESTIMATION
    M = [ 1,-2, 1;
         -2, 4,-2;
          1,-2, 1];    
    convolve = conv2(img, M);
    convoluve_abs = abs(convolve);
    summation = sum(convoluve_abs(:));
    
    k = size(img, 2);
    l = size(img, 1);
    sigma = sqrt((pi / 2) * (1 / (6 * (k - 2) * (l - 2))) * summation);
end

function [result] = process_subband_matrix(CoeffMatrix, sigma)
    %For each sub matrix find the maximum value and use it to calculate
    %variable m (lowercase), this is based upon the following paper.
    % WAVELET IMAGE DE-NOISING METHOD BASED ON NOISE STANDARD DEVIATION ESTIMATION 
    Mij = max(CoeffMatrix(:));
    K = 1;
    m = K*(Mij - sigma);
    
    %Loop on each value within the CoeffMatrix and apply the yalpha
    %function to each value and then multiply the results by the output
    CoeffMatrixSize = size(CoeffMatrix);
    for y=1:CoeffMatrixSize(1)
        for x=1:CoeffMatrixSize(2)
            CoeffValue = CoeffMatrix(y, x);
            new_CoeffValue = yalpha(CoeffValue, sigma, m);
            CoeffMatrix(y, x) = CoeffValue * new_CoeffValue;
        end
    end
    
    result = CoeffMatrix;
end

function [result] = yalpha(x, sigma, m)
    a = 3;
    p = 1;
    q = 1;
    c = sigma;
    
    if(abs(x) < (a*c))
        result = 1;
    elseif((a*c) <= abs(x) && abs(x) < (2*a*c))
        result = ((abs(x) - (a*c) / (a*c)) * ((m / (a*c))^p)) + (((2*a*c) - abs(x)) / (a*c));
    elseif((2*a*c) <= abs(x) && abs(x) < m)
        result = ((m / abs(x))^p);
    elseif(m <= abs(x))
        result = ((m / abs(x))^q);
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

