function [result] = align_images_coor(img1, img2)
	addpath('crosscoor');
    addpath('skel_endpoints');
    
    image1 = double(imread(img1))/256;
	image2 = double(imread(img2))/256;

    minx = min_axis(image1, image2, 1);
    miny = min_axis(image1, image2, 2);
    
    image1 = imresize(image1, [minx, miny]);
    image2 = imresize(image2, [minx, miny]);

	cc = correlCorresp('image1', image1, 'image2', image2, 'printProgress', 100);
    cc.relThresh = 0.4;
    cc.convTol = 0.05; 
	cc = cc.findCorresps;
    
    figure(1);
    correspDisplay(cc.corresps, image1);
    %figure(2);
	%correspEdgeDisplay(cc.corresps, 'projective', image1, image2);
    
    temp = most_common(cc.corresps);
    figure(3);
    correspDisplay(temp, image1);
end

function [quad] = which_quad(x, y, xaxis, yaxis)
    % Break the image up into the following quadrant
    % ---------
    % | 1 | 2 |
    % ---------
    % | 4 | 3 |
    % ---------
    
    if x <= (xaxis / 2.0)
        if y <= (yaxis / 2.0)
            quad = 1;
        else
            quad = 4;
        end
    else
        if y <= (yaxis / 2.0)
            quad = 2;
        else
            quad = 3;
        end
    end
end

function [out] = min_axis(img1, img2, dim)
    min = size(img1, dim);
    
    if(size(img2, dim) < min)
       min =  size(img2, dim);
    end
    
    out = min;
end