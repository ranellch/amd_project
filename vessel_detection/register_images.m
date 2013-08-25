function [new_base_filename, new_corr_filename] = register_images(...
                                                base_img_real_file, transformbase, ...
                                                next_img_real_file, transformnext, ...
                                                outputdir)
	%Update console and user with information about image registration
	disp('==============================================================');
	disp([base_img_real_file, ' - ', next_img_real_file, ' => ', outputdir]);
    
	%Create the output directory for this badboy
	if exist(outputdir, 'dir') == false
		mkdir(outputdir); 
    end
       
	%Read in the files to attempt to register
	base_img_real = imread(base_img_real_file);
	next_img_real = imread(next_img_real_file);
    
    if length(size(base_img_real)) == 3 
        base_img_real = rgb2gray(base_img_real);
    end
    if length(size(next_img_real)) == 3
        next_img_real = rgb2gray(next_img_real);
    end
    
    %Remove the footer from the image
    base_img_real = crop_footer(base_img_real);
    next_img_real = crop_footer(next_img_real);
    
    %Apply necessary transforms to images to prepare for vessel detection
    base_img_vd = prepare_image(base_img_real, transformbase);
    next_img_vd = prepare_image(next_img_real, transformnext);
    
	%Get the vessel outline of each image
	base_img = vessel_detection(base_img_vd);
	next_img = vessel_detection(next_img_vd);
    
	%Find the tform matrix to alter next_img to be like base_img
	skip_quad = zeros(1,1);
	skip_quad(1, 1) = 5;
	quad_count = 3;
	tform = align_images_coor(base_img, next_img, quad_count, skip_quad);
    
	%Apply the tform transform to the original images
	[img1_correct, img2_correct] = apply_transform(tform, base_img_real, next_img_real);

	%Get the filenames
 	count1 = parse_outname(base_img_real_file);
	count2 = parse_outname(next_img_real_file);

	%Build the output file name
	new_base_filename = [outputdir, '/', count1, '-', count2, '_baseimg.tif'];
	new_corr_filename = [outputdir, '/', count1, '-', count2, '_corrimg.tif'];
    
	%Write the corrected image pair to disk
	imwrite(img1_correct, new_base_filename, 'tif');
	imwrite(img2_correct, new_corr_filename, 'tif');
end

