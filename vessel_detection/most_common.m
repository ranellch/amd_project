function [outer] = most_common(matrix, breakup, quad_skip, minx, miny)
    %Get the size of the correlated points
    size_of_it = size(matrix(1,:), 2);
    diff = zeros(size_of_it, 6);
    
    %Calcualte the x and y offest of matched points
    for index=1:size_of_it
        x1 = matrix(1,index);
        y1 = matrix(2,index);
        
        x2 = matrix(3,index);
        y2 = matrix(4,index);
        
        %Get the distance between the two points
        diff(index, 1) = round(sqrt(power(x2 - x1, 2) + power(y2 - y1, 2)));
        
        %Get the quad that this things starts in
        diff(index, 2) = which_quad(x1, y1, minx, miny, breakup);
        
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
    quad_mode = zeros((length(keys) - length(quad_skip)), 4);
    quad_mode_index = 1;
    final_length = 0;
    
    %Find the mode and the count for each quad
    sindex = 1;
    eindex = 1;
    for quad=1 : length(keys)
        %Check to make sure that this is not one of the quads to skip
        if(isempty(find(quad_skip == keys(quad), 1)))
            %Find the index of the first element in this quad
            while(sindex <= size_of_it && sortedIt(sindex, 2) ~= keys(quad))
                sindex = sindex + 1;
            end
            if(sindex > size_of_it)
                sindex = size_of_it;
            end
            
            %find the index of the last element in this quad
            eindex = sindex;
            while(eindex <= size_of_it && sortedIt(eindex, 2) == keys(quad))
                eindex = eindex + 1;
            end
            if(eindex > size_of_it)
                eindex = size_of_it;
            end
            
            %Create a list of possible modes
            possible_modes = sort(unique(sortedIt(sindex:eindex, 1)));
            possible_frequencies = zeros(length(possible_modes), 1);
            biggest_mode = 0;
            biggest_mode_index = 0;
            
            %Find the frequency of each of the modes
            for i=1:length(possible_modes)
                possible_frequencies(i, 1) = length(find(sortedIt(sindex:eindex, 1) == possible_modes(i)));
                if(biggest_mode < possible_frequencies(i, 1))
                   biggest_mode = possible_frequencies(i, 1);
                   biggest_mode_index = i;
                end
            end
            
            %Calculate the most frequent change and get the points on either side of it
            quad_mode(quad_mode_index, 1) = keys(quad);
            quad_mode(quad_mode_index, 2) = possible_modes(biggest_mode_index, 1) - 1;
            quad_mode(quad_mode_index, 3) = possible_modes(biggest_mode_index, 1);
            quad_mode(quad_mode_index, 4) = possible_modes(biggest_mode_index, 1) + 1;
            
            %Try to get the frequency of the length from one bin above the biggest
            final_length = final_length + length(find(sortedIt(sindex:eindex, 1) == quad_mode(quad_mode_index, 2)));
            
            %Get the frequency of the mode bin
            final_length = final_length + biggest_mode;

            %Get the frequency of the length from one bin below the biggest
            final_length = final_length + length(find(sortedIt(sindex:eindex, 1) == quad_mode(quad_mode_index, 4)));
            
            quad_mode_index = quad_mode_index + 1;
            
            sindex = eindex;
        end
    end
    
    %Get the x,y matched pairs for the mode of each quad
    combined = zeros(4, final_length);
    curcount = 0;
    sindex = 1;
    eindex = 1;
    for quad=1 : length(quad_mode)
        %Find the start of this quad
        while(sindex <= size_of_it && sortedIt(sindex, 2) ~= quad_mode(quad, 1))
            sindex = sindex + 1;
        end
        if(sindex > size_of_it)
                sindex = size_of_it;
        end
        
        %Loop on each correlated point in this quad
        eindex = sindex;
        while(eindex <= size_of_it && sortedIt(eindex, 2) == quad_mode(quad, 1))
            change = sortedIt(eindex, 1);
            if (change == quad_mode(quad, 2)) || (change == quad_mode(quad, 3)) || (change == quad_mode(quad, 4))
                curcount = curcount + 1;
                combined(1, curcount) = int32(sortedIt(eindex, 3));
                combined(2, curcount) = int32(sortedIt(eindex, 4));
                combined(3, curcount) = int32(sortedIt(eindex, 5));
                combined(4, curcount) = int32(sortedIt(eindex, 6));
            end
            eindex = eindex + 1;
        end
        sindex = eindex;
    end
    
    if(curcount ~= final_length)
        if(curcount < final_length)
            combined(:, final_length) = [];
        end
        msg = (['The curcount (', num2str(curcount),') variable did not match the final_length (', num2str(final_length) ,') variable in most_common.m']);
        disp(msg);
    end
    
    disp(['Found X-Y Correlated Modal Matches: ', num2str(length(combined))]);
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
    
    %Build the matrix of coordinates
    matrix = zeros(breakup);
    tile = 1;
    for ycont=drange(1:breakup)
        for xcont=drange(1:breakup)
            matrix(ycont, xcont) = tile;
            tile = tile + 1;
        end
    end
       
    %Get the index of the x and y
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
