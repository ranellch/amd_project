function [outer] = most_common(matrix, minx, miny)
    %Get the size of the correlated points
    size_of_it = size(matrix(1,:), 2);
    diff = zeros(size_of_it, 6);
    
    %Calcualte the x and y offest of matched points
    for index = 1:size_of_it
        x1 = matrix(1,index);
        y1 = matrix(2,index);
        
        x2 = matrix(3,index);
        y2 = matrix(4,index);
        
        %Get the distance between the two points
        diff(index, 1) = round(sqrt(power(x2 - x1, 2) + power(y2 - y1, 2)));
        
        %Get the quad that this things starts in
        diff(index, 2) = which_quad(x1, y1, minx, miny, 3);
        
        %Get the x and y correlated points
        diff(index, 3) = x1;
        diff(index, 4) = y1;
        diff(index, 5) = x2;
        diff(index, 6) = y2;
    end
    
    %Find the most common transform values
    sortedIt = sortrows(diff, [2, 1]);
    
    %Find the unique quads
    keys = unique(sortedIt(:,2));
    quad_mode = zeros(length(keys), 2);
    final_length = 0;
    
    %Find the mode and the count for each quad
    sindex = 1;
    eindex = 1;
    for quad=1 : length(keys)
        while(sindex < size_of_it && sortedIt(sindex, 2) ~= keys(quad))
            sindex = sindex + 1;
        end
        eindex = sindex;
        while(eindex < size_of_it && sortedIt(eindex, 2) == keys(quad))
            eindex = eindex + 1;
        end
        
        [M, F] = mode(sortedIt(sindex:eindex, 1));
        quad_mode(quad, 1) = M;
        quad_mode(quad, 2) = F;
        
        final_length = final_length + F;
               
        sindex = eindex;
    end
    
    %Get the x,y matched pairs for the mode of each quad
    combined = zeros(4, final_length);
    curcount = 1;
    sindex = 1;
    eindex = 1;
    for quad=1 : length(quad_mode)
        %Find the start of this badboy
        while(sindex < size_of_it && sortedIt(sindex, 2) ~= keys(quad))
            sindex = sindex + 1;
        end
        eindex = sindex;
        while(eindex < size_of_it && sortedIt(eindex, 2) == keys(quad))
            if (sortedIt(eindex, 1) == quad_mode(quad, 1))
                combined(1, curcount) = sortedIt(eindex, 3);
                combined(2, curcount) = sortedIt(eindex, 4);
                combined(3, curcount) = sortedIt(eindex, 5);
                combined(4, curcount) = sortedIt(eindex, 6);
                curcount = curcount + 1;
            end
            eindex = eindex + 1;
        end
        sindex = eindex;
    end
    
    disp(strcat('Found X-Y Correlated Modal Matches: ', num2str(length(combined))));
    outer = combined;
end

function [quad] = which_quad(x, y, xaxis, yaxis, breakup)
    % Break the image up into the following quadrant
    % -------------
    % | 1 | 2 | 3 |
    % -------------
    % | 4 | 5 | 6 |
    % -------------
    % | 7 | 8 | 9 |
    % -------------
    
    matrix = zeros(3);
    matrix(1,1) = 1;
    matrix(1,2) = 2;
    matrix(1,3) = 3;
    
    matrix(2,1) = 4;
    matrix(2,2) = 5;
    matrix(2,3) = 6;
    
    matrix(3,1) = 7;
    matrix(3,2) = 8;
    matrix(3,3) = 9;
    
    xindex = 0;
    yindex = 0;
    
    xstep = xaxis / breakup;
    for stepit=drange(1:breakup)
        if (x <= (xstep * stepit))
            xindex = stepit;
            break;
        end
    end
    
    ystep = yaxis / breakup;
    for stepit=drange(1:breakup)
        if(y <= (ystep * stepit))
            yindex = stepit;
            break;
        end
    end
     
    quad = matrix(yindex, xindex);
end
