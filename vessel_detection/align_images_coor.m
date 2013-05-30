function [result] = align_images_coor(img1, img2)
	addpath('crosscoor');
    addpath('skel_endpoints');
    
    image1 = double(imread(img1))/256;
	image2 = double(imread(img2))/256;

    minx = min_axis(image1, image2, 1);
    miny = min_axis(image1, image2, 2);
    
    image1 = imresize(image1, [minx, miny]);
    image2 = imresize(image2, [minx, miny]);

	cc = correlCorresp('image1', image1, 'image2', image2);%, 'printProgress', 100);
    cc.relThresh = 0.4;
    cc.convTol = 0.05; 
	cc = cc.findCorresps;
    
	correspEdgeDisplay(cc.corresps, 'projective', image1, image2);
    
    xdiff = 0.0;
    ydiff = 0.0;
    size_of_it = size(cc.corresps(1,:), 1);
    for index = 1:size_of_it
        x1 = cc.corresps(1,index);
        x2 = cc.corresps(3,index);
        
        xdiff = xdiff + (x2 - x1);
        
        y1 = cc.corresps(2,index);
        y2 = cc.corresps(4,index);
        
        ydiff = ydiff + (y2 - y1);
    end
    
    xdiff = xdiff / size_of_it;
    ydiff = ydiff / size_of_it;
    
    result = [xdiff, ydiff];
end

function [out] = min_axis(img1, img2, dim)
    min = size(img1, dim);
    
    if(size(img2, dim) < min)
       min =  size(img2, dim);
    end
    
    out = min;
end