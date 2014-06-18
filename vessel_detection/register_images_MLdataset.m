function [new_base_filename, new_corr_filename] = register_images_MLdataset(...
                                                base_img_real_file, ...
                                                next_img_real_file, pid, ...
                                                outputdir, resize)
	%Update console and user with information about image registration
	disp('==============================================================');
	disp([base_img_real_file, ' - ', next_img_real_file, ' => ', outputdir]);
    
	%Create the output directory for this badboy
	if exist(outputdir, 'dir') == false
		mkdir(outputdir); 
    end
    
    %Add the location of the images
    addpath(genpath('../Test Set'));
       
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
    
    %Resize to 768 by 768 if specified
    if resize
        base_img_real = imresize(base_img_real, [768 768]);
        next_img_real = imresize(next_img_real, [768 768]);
    end
    
    
	%Get the vessel outline of each image from already classified images
	base_img = imread( [pid, '-1-lineop vessels.tif']);
	next_img = imread( [pid, '-2-lineop vessels.tif']);
      
    base_img = clean_binary( base_img, 0 );
    next_img = clean_binary( next_img, 0 );
    
    %write cleaned up images
    imwrite(base_img, [outputdir, '/', base_img_real_file, '-vessels.tif'], 'tiff');
    imwrite(next_img, [outputdir, '/', next_img_real_file, '-vessels.tif'], 'tiff');
    
	%Find the correspondence between the two sets of images
	skip_quad = zeros(1,1);
	skip_quad(1, 1) = 5;
	quad_count = 3;
	[pointsA, pointsB] = align_images_coor(base_img, next_img, quad_count, skip_quad);
    
    %Estimate the image transform and get the tform matrix
    [theta, scale, translation, tform] = transform_it_vision(pointsA, pointsB);
    disp(['Correcting Image: theta: ' , num2str(theta), ' scale: ', num2str(scale), ...
            ' x: ', num2str(translation(1)), ' y: ', num2str(translation(2))]);
    
	%Apply the tform transform to the original images
	[img1_correct, img2_correct] = apply_transform(tform, base_img_real, next_img_real);

	%Get the filenames for the output
 	count1 = parse_outname(base_img_real_file);
	count2 = parse_outname(next_img_real_file);

	%Build the output file name
	new_base_filename = [outputdir, '/', count1, '-', count2, '_baseimg.tif'];
	new_corr_filename = [outputdir, '/', count1, '-', count2, '_corrimg.tif'];
    
	%Write the corrected image pair to disk
	imwrite(img1_correct, new_base_filename, 'tif');
	imwrite(img2_correct, new_corr_filename, 'tif');
end

