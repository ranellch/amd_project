function classify(pid, time, number_of_pixels)
    addpath('..');
    addpath('../Test Set');

    the_path = get_path(pid, time);
    image = im2double(imread(the_path));

    load('svm_model.mat', 'SVMstruct');

    bin_image = zeros(size(image, 1), size(image, 2)); 
    iterations = floor(size(image, 1) / number_of_pixels);
    
    %Go down the left side of the image
    for x=1:iterations
        for y=1:iterations
            ys = ((y - 1) * number_of_pixels) + 1;
            xs = ((x - 1) * number_of_pixels) + 1;
            if(xs + number_of_pixels <= size(image, 2) && ys + number_of_pixels <= size(image, 1))
                subimage = image(ys:ys+number_of_pixels,xs:xs+number_of_pixels);
                grouping = class_image(subimage, SVMstruct);
                disp(grouping);
                if grouping == 1
		   bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 0);
                else
		    bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 1);
                end  
            end
        end
    end
end

function output = apply_bin_to_arr(output, ys, xs, number_of_pixels, val)
    for y=ys:ys+number_of_pixels
        for x=xs:xs+number_of_pixels
            output(y, x) = val;
        end
    end
end

function grouping = class_image(img, SVMstruct)
    %hogin = HOG(img);
    lbpin = lbp(img, 1, 8, 'h');

    final = zeros(1, size(lbpin, 2));
    final_index = 1;
    for x=1:size(lbpin, 2)
        final(1, final_index) = lbpin(1, x);
        final_index = final_index + 1;
    end

    grouping = svmclassify(SVMstruct, final);
    return;
end
