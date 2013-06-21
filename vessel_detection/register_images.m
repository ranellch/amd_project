function [new_base_filename, new_corr_filename] = register_images(base_img_real, next_img_real, outputdir)
    %Create the output directory for this badboy
    if exist(outputdir, 'dir') == false
       mkdir(outputdir); 
    end
    
    %Get the vessel outline of each image
    [~, base_img] = vessel_detection(base_img_real, outputdir);
    [~, next_img] = vessel_detection(next_img_real, outputdir);
    
    %Find the tform matrix to alter next_img to be like base_img
    skip_quad = zeros(1,1);
	skip_quad(1, 1) = 5;
	quad_count = 3;
	tform = align_images_coor(base_img, next_img, quad_count, skip_quad);
    
	%Apply the tform transform to the original images
	[img1_correct, img2_correct] = apply_transform(tform, base_img_real, next_img_real);
    
    count1 = parse_outname(base_img_real);
    count2 = parse_outname(next_img_real);

    new_base_filename = [outputdir, '/', count1, '-', count2, '_baseimg.tif'];
    new_corr_filename = [outputdir, '/', count1, '-', count2, '_corrimg.tif'];
    
	%Write the corrected image pair to disk
    imwrite(img1_correct, new_base_filename, 'tif');
    imwrite(img2_correct, new_corr_filename, 'tif');
end

