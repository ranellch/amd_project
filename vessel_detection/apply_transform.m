function [img1out, img2out] = apply_transform(tform, imgbase, img2)
	image1 = im2double(imread(imgbase));
    image2 = im2double(imread(img2));
        
    minx = min_axis(image1, image2, 1);
    miny = min_axis(image1, image2, 2);
    
    img1out = imresize(image1, [minx, miny]);
    image2 = imresize(image2, [minx, miny]);
    
    agt = vision.GeometricTransformer;
    img2out = step(agt, image2, tform);
end

function [out] = min_axis(img1, img2, dim)
    min = size(img1, dim);
    
    if(size(img2, dim) < min)
       min =  size(img2, dim);
    end
    
    out = min;
end