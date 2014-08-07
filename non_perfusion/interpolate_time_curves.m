function [result] = interpolate_time_curves(xinter, x_values, scatter, positive_image)
    %Build results matrix for each pixel
    result = double(zeros(size(scatter,1), size(scatter,2), size(scatter, 4), size(xinter,2)));
    
    disp('[INTERPOLATING] Running interpolation on each pixel,feature');

    %Loop on each pixel in the image set
    for y=1:size(scatter,1)
        for x=1:size(scatter,2)
            if(positive_image(y,x) == 1)
                for z=1:size(scatter,4)
                    y_values = interp1(x_values, squeeze(scatter(y,x,:,z)), xinter, 'spline');
                    result(y,x,z,:) = y_values(:);
                end
            end
        end
        
        if(mod(y, 50) == 0)
            disp(['     ', num2str(y), ' / ', num2str(size(scatter, 1))]);
        end
    end
end
