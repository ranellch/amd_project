function [outer] = most_common(matrix)
    %Get the size of the correlated points
    size_of_it = size(matrix(1,:), 2);
    xdiff = zeros(size_of_it, 1);
    ydiff = zeros(size_of_it, 1);
    
    %Calcualte the x and y offest of matched points
    for index = 1:size_of_it
        x1 = matrix(1,index);
        y1 = matrix(2,index);
        
        x2 = matrix(3,index);
        y2 = matrix(4,index);
        
        xdiff(index, 1) = (x2 - x1);
        ydiff(index, 1) = (y2 - y1);
    end

    %Calculate the most common x and y transform
    most_common_x = most_common_values(xdiff);
    most_common_y = most_common_values(ydiff);
    
    %Find the most common transform values
    sortedX = sortrows(most_common_x, -2);
    sortedY = sortrows(most_common_y, -2);
    
    %Count how many points occur in top matches
    xcount = 0;
    ycount = 0;
    top = 2;
    for i = 1: top
        xcount = xcount + sortedX(i, 2);
        ycount = ycount + sortedY(i, 2);
    end
    
    %build holder of index output
    xout = zeros(xcount, 1);
    xtrack = 1;
    yout = zeros(ycount, 1);
    ytrack = 1;
    
    for i = 1: top
        xval = sortedX(i, 1);
        yval = sortedY(i, 1);
        
        ind_x = find(xval == xdiff);
        for j = 1: length(ind_x)
            xout(xtrack) = ind_x(j);
            xtrack = xtrack + 1;
        end
        
        ind_y = find(yval == ydiff);
        for j = 1: length(ind_y)
            yout(ytrack) = ind_y(j);
            ytrack = ytrack + 1;
        end
    end
    
    combined = intersect(xout, yout);
    disp(strcat('Found X-Y Correlated Modal Matches: ', num2str(length(combined))));
    
    outer = zeros(4, length(combined));
    for i = 1: length(combined)
        the_index = combined(i);
        outer(1, i) = matrix(1, the_index);
        outer(2, i) = matrix(2, the_index);
        outer(3, i) = matrix(3, the_index);
        outer(4, i) = matrix(4, the_index);
    end
end

function [outer] = most_common_values(diff)
    keys = unique(diff);
    outer = zeros(length(keys), 2);

    for i = 1: length(keys)
        temp = length(find(keys(i) == diff));
        outer(i, 1) = keys(i);
        outer(i, 2) = temp;
    end
end