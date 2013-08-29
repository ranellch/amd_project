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
    
    %Rebuild the image using the modified coefficient values
    Y = real(ifdct_wrapping(C,0));
    
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
    
    figure(2);
    subplot(1,2,1); colormap gray; imagesc(real(I)); axis('image'); title('original image');
    subplot(1,2,2); colormap gray; imagesc(real(Y)); axis('image'); title('partial reconstruction');
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

