function [image] = vessel_detection(img)
    %Get the image and convert to graysacle
	original = img;
    
    %Remove the footer from the image
    %original = crop_footer(original);
    
    %Run Gaussian filter
    g_filter = imfilter(original, fspecial('gaussian', [5 5], 1.2), 'same');

    %Run closure on the image
    close_filter = imclose(g_filter, strel('square', 3));
    
    %Run BTH operator
    bthval = imclose(close_filter, strel('square', 31));
    out = imsubtract(bthval, close_filter);
      
    mean_val = double(0);
    count = 0;
    for y = 1:size(out,1)
        for x = 1:size(out,2)
            mean_val = mean_val + double(out(y, x));
            count = count + 1;
        end
    end
    mean_val = mean_val / count;

    %Calculate the standard deviation for the distribution of gray sacle values
    variance = double(0);
    for y = 1:size(out,1)
        for x = 1:size(out,2)
            variance = variance + power((mean_val - double(out(y, x))), 2);
        end
    end
    stddev = sqrt(variance / count);

    %From the mean and std dev calculate the threshold as one stddev
    threshold = mean_val + (stddev * .4);

    fout = im2bw(out);
    
    %Threshold this badboy
    for x=1:size(out,2)
        for y = 1:size(out,1)
            pixel = out(y, x);
            if(pixel < threshold)
                fout(y, x) = 0;
            else
                fout(y, x) = 1;
            end
        end
    end
    
    %Calculate the skeleton on the image
    out = bwareaopen(fout, 20);
    out = bwmorph(out, 'bridge');
    out = bwmorph(out, 'thin', Inf);
    out = bwmorph(out, 'fill');
    out = bwmorph(out, 'spur');
    out = bwmorph(out, 'thin', Inf);
    out = bwareaopen(out, 20);
    
    %Return the image
    image = out;
end


