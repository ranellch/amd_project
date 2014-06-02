function [od_image] = find_od()
%Standardize variables
std_img_size = 768;
number_of_pixels_per_box = 8;

%Add the path for the images
addpath('..');
addpath('../Test Set');
addpath('../intensity normalization');
addpath(genpath('../sfta'));
run('../vlfeat/toolbox/vl_setup');

%Get the images to include from this list
fid = fopen('od_draw_test.dataset', 'r');
includes = textscan(fid,'%q %q %d %*[^\n]');
fclose(fid);

pid = 'none';
eye = 'none';
time = -1;
for x=1:size(includes{1}, 1)
    pid = char(includes{1}{x});
    eye = char(includes{2}{x});
    time = num2str(includes{3}(x));  
        
    %Get the path name from the image and time and then read in the image.
    filename = get_pathv2(pid, eye, time, 'original');
    img = imread(filename);
    img = im2double(img);

    %Convert the image to gray scale if not already
    if(size(img,3) ~= 1)
        img=rgb2gary(img);
    end

    %Apply a gaussian filter to the image
    img = gaussian_filter(img);

    %Resize the image to a standard size
    origy = size(img, 1);
    origx = size(img, 2);
    img = match_sizing(img, std_img_size, std_img_size);

    %Print to the console the output
    disp(['ID: ', pid, ' - Time: ', time]);

    %Load the prediction structs
    load('od_classify_svmstruct.mat', 'od_classify_svmstruct');

    x=-1;
    y=-1;

    od_image = zeros(size(img, 1), size(img, 2));

    %Divide the image up into equal sized boxes
    subimage_size = floor(std_img_size / number_of_pixels_per_box);
    
    if 0
        %This is a window based feature descriptor
        for x=1:subimage_size
            for y=1:subimage_size
                xs = ((x - 1) * number_of_pixels_per_box) + 1;
                xe = xs + number_of_pixels_per_box - 1;

                ys = ((y - 1) * number_of_pixels_per_box) + 1;
                ye = ys + number_of_pixels_per_box - 1;

                if(ye > size(img, 1))
                    ye = size(img, 1);
                    ys = ye - number_of_pixels_per_box;
                end
                if(xe > size(img, 2))
                    xe = size(img, 2);
                    xs = xe - number_of_pixels_per_box;
                end

                %Get the original image window
                subimage = img(ys:ye, xs:xe);

                feature_vectors = text_algorithm(subimage);
                grouping = svmclassify(od_classify_svmstruct, feature_vectors);

                for xt=xs:xe
                    for yt=ys:ye
                        od_image(yt,xt) = grouping;
                    end
                end
            end
        end        
    elseif 1
        %Run the gabor stuff
        [sizey, sizex] = size(img);
        bigimg = padarray(img, [50 50], 'symmetric');
        fimg = fft2(bigimg);
        k0x = 0;
        k0y = 3;
        epsilon = 1;
        step = 10;
        gabor_image = [];
        for a = [1 2 3 4 5]
            trans = maxmorlet(fimg, a, epsilon, [k0x k0y], step);
            trans = trans(51:(50+sizey), (51:50+sizex));
            gabor_image = cat(3, gabor_image, zero_m_unit_std(trans));
        end 
        
        gabor_vectors = matstack2array(gabor_image);
        
        class_estimates = [];
        increment = length(gabor_vectors)/512;
        for start = 1:increment:length(gabor_vectors)
            class_estimates = [class_estimates; svmclassify(od_classify_svmstruct, gabor_vectors(start:start+increment-1,:))];
        end
        
        od_image(:) = class_estimates;
    elseif 0
        texture_results = vl_hog(single(img), number_of_pixels_per_box, 'verbose') ;
        
        for y=1:size(texture_results,1)
            for x=1:size(texture_results,2)
                class_estimates = svmclassify(od_classify_svmstruct, squeeze(texture_results(y,x,:)).');
                
                od_image(((y-1)*number_of_pixels_per_box)+1:y*number_of_pixels_per_box, ((x-1)*number_of_pixels_per_box)+1:x*number_of_pixels_per_box) = class_estimates;
            end
        end
    end
    
    figure(1), imshowpair(od_image, img);

    %Resize the image to its original size
    od_image = match_sizing(od_image, origx, origy);
end

end