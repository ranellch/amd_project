function [img1out, img2out] = apply_transform(tform, imgbase, img2)
	img1out = im2double(imgbase);
    image2 = im2double(img2);
            
    agt = vision.GeometricTransformer;
    img2out = step(agt, image2, tform);
end
