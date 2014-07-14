function [vsl_img] = find_vessels(img, varargin)
    debug = -1;
    if length(varargin) == 1
        debug = varargin{1};
    elseif isempty(varargin)
        debug = 1;
    else
        throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
    end
    
    addpath('np_vessel');
    
    %Check to see that the path to the image is readable
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    img = im2double(img);

    origy = size(img, 1);
    newy = 768;
    img_resized = imresize(img, [newy NaN]);
    vsl_img = vesselDetect(img_resized, 'matching');
    
    vsl_img = imresize(vsl_img, [origy, NaN]);
end