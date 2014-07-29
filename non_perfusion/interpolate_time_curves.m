function [xinter, result] = interpolate_time_curves(step, x_values, scatter, positive_image)
    %Calculate the vector that is going to be the interpolation query
    xinter = min(x_values(:)):step:max(x_values(:));
    
    %Build results matrix for each pixel
    result = double(zeros(size(scatter,1), size(scatter,2), size(scatter, 4), size(xinter,2)));
    
    %Loop on each pixel in the image set
    for y=1:size(scatter,1)
        if(mod(y, 15) == 0)
            disp([num2str(y), ' / ', num2str(size(scatter,1))]);
        end
        
        for x=1:size(scatter,2)
            if(positive_image(y,x) == 1)
                for z=1:size(scatter,4)
                    y_values = interpolate(x_values, squeeze(scatter(y,x,:,z)), xinter);
                    result(y,x,z,:) = y_values(:);
                end
            end
        end
    end
end

function [yinter] = interpolate(x_values, y_values, query)    
    yinter = interp1(x_values, y_values, query, 'spline');
end