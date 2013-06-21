function [img1out, img2out] = apply_transform(tform, imgbase, img2)
	image1 = im2double(imgbase);
    image2 = im2double(img2);
        
    miny = min_axis(image1, image2, 1);
    minx = min_axis(image1, image2, 2);
    
    img1out = imresize(image1, [minx, miny]);
    image2 = imresize(image2, [minx, miny]);
    
    agt = vision.GeometricTransformer;
    img2out = step(agt, image2, tform);
end
