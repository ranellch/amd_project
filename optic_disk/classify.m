function classify(pid, time, number_of_pixels)
    %Add some paths to make this
    addpath('..');
    addpath('../Test Set');

    %Get the path and read in the image
    the_path = get_path(pid, time);
    image = im2double(imread(the_path));
    
    figure(1);
    imshow(image);
    
    %If image is rgb convert to gray scale
    if(size(image, 3) > 1)
        image = rgb2gray(image);
    end

    %Load the svm_model variable from the current directory
    load('prediction_struct.mat', 'prediction_struct');

    bin_image = zeros(size(image, 1), size(image, 2)); 
    iterations = floor(size(image, 1) / number_of_pixels);
    
    %Go down the left side of the image
    for x=1:iterations
        for y=1:iterations
            ys = ((y - 1) * number_of_pixels) + 1;
            xs = ((x - 1) * number_of_pixels) + 1;
            if(xs + number_of_pixels <= size(image, 2) && ys + number_of_pixels <= size(image, 1))
                subimage = image(ys:ys+number_of_pixels,xs:xs+number_of_pixels);
                
                grouping = class_img(subimage, prediction_struct);
                
                if grouping == 1
                    bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 1);
                else
                    bin_image = apply_bin_to_arr(bin_image, ys, xs, number_of_pixels, 0);
                end
            end
        end
    end
    
    figure(2);
    imshow(bin_image);
end

function output = apply_bin_to_arr(output, ys, xs, number_of_pixels, val)
    for y=ys:ys+number_of_pixels
        for x=xs:xs+number_of_pixels
            output(y, x) = val;
        end
    end
end
