function [finalroimask] = find_roi(img, varargin)
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
    end

    t = cputime;
    
    %Add some sweet paths
    addpath(genpath('../liblinear-1.94'))
    addpath('..');
    run('../vlfeat/toolbox/vl_setup');
        
    %Convert the image to grayscale from color if necessary
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    
    %Load the classifer scripts
    model = load('roi_classify_svmstruct.mat');
    scaling_factors = model.scaling_factors;
    classifier = model.roi_classify_svmstruct;
    
    %From the image use the classifier to get image
    roimask = lbp_image(img, classifier, scaling_factors);
        
    %Find the largest connected component
    finalroimask = zeros(size(roimask,1), size(roimask,2));
    CC = bwconncomp(roimask);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
    finalroimask(CC.PixelIdxList{idx}) = 1;
    finalroimask = bwmorph(finalroimask, 'majority');
    
    if(debug == 2)
        figure(1), imshow(finalroimask);
    end
    
    if(debug == 1 || debug == 2)
        e = cputime - t;
        disp(['[ROI] Run Classifier Time (sec): ', num2str(e)]);
    end
end
