function [xinter, result] = interpolate_time_curves(step, x_values, scatter)
    %Calculate the vector that is going to be the interpolation query
    xinter = min(x_values(:)):step:max(x_values(:));
    
    %Build results matrix for each pixel
    result = double(zeros(size(scatter,1), size(scatter,2), size(xinter,1)));
    
    %Loop on each pixel in the image set
    for y=1:size(scatter,1)
        for x=1:size(scatter,2)
            for z=1:size(scatter,3)
                y_values = interpolate(x_values, squeeze(scatter(y,x,:,z)), xinter);
                result(y,x,:) = y_values(:);
            end
        end
    end
end

function [yinter] = interpolate(x_values, y_values, query)
    for i=1:numel(x_values)
        disp([num2str(x_values(i,1)) , ': ', num2str(y_values(i,1))]);
    end
    
    yinter = interp1(x_values, y_values, query, 'spline');
end