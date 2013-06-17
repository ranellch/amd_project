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
    
    %Get the most common points in each quad
    temp = most_common(cc.corresps, minx, miny);
    
    figure(2);
    correspDisplay(temp, image1);

    %Form arry in the correct manner
    pointsA = temp(1:2,:)';
    pointsB = temp(3:4,:)';
    
    csvwrite('pointsA.csv', pointsA);
    csvwrite('pointsB.csv', pointsB);
    
    result = temp;
end

function [out] = min_axis(img1, img2, dim)
    min = size(img1, dim);
    
    if(size(img2, dim) < min)
       min =  size(img2, dim);
    end
    
    out = min;
end