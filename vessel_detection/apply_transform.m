function [img1out, img2out] = apply_transform(tform, imgbase, img2)
	image1 = im2double(imgbase);
    image2 = im2double(img2);
    
	%resize the images
    [img1out, image2] = match_sizing(image1, image2);
        
    agt = vision.GeometricTransformer;
    img2out = step(agt, image2, tform);
end
