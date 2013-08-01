function [outer] = most_common(matrix, breakup, quad_skip, minx, miny)
    %Get the size of the correlated points
    size_of_it = size(matrix(1,:), 2);
    diff = zeros(size_of_it, 7);
    
    %Calcualte the x and y offest of matched points
    for index=1:size_of_it
        x1 = matrix(1,index);
        y1 = matrix(2,index);
        
        x2 = matrix(3,index);
        y2 = matrix(4,index);
        
        %Get the distance between the two points
        diff(index, 1) = round(x2 - x1);
        diff(index, 2) = round(y2 - y1);
        
        %Get the quad that this things starts in
        diff(index, 3) = which_quad(x1, y1, minx, miny, breakup);
        
        %Get the x and y correlated points
        diff(index, 4) = x1;
        diff(index, 5) = y1;
        diff(index, 6) = x2;
        diff(index, 7) = y2;
    end
    
    disp(['Initial X-Y Correlated Modal Matches: ', num2str(size_of_it)]);
    
    %Get the modes for the different axis x then y
    [xindex, xmode_val] = find_mode(diff, 3, 1, quad_skip);
    [yindex, ymode_val] = find_mode(diff, 3, 2, quad_skip);
    
    index_intersect = intersect(xindex, yindex);
    disp(['Cleaned X-Y Correlated Modal Matches: ', num2str(length(index_intersect))]);
    
    outer = zeros(4, length(index_intersect));
    minus = 0;
    for count=1:length(index_intersect)
        if(index_intersect(count) > 0)
            outer(1, count - minus) = diff(index_intersect(count), 4);
            outer(2, count - minus) = diff(index_intersect(count), 5);
            outer(3, count - minus) = diff(index_intersect(count), 6);
            outer(4, count - minus) = diff(index_intersect(count), 7);
        else
            outer(:, length(index_intersect) - minus) = [];
            minus = minus + 1;
        end
    end
end

function [indexed, mode_val] = find_mode(the_list, quad_index, diff_index, quad_skip)
    %Get the size of this array
    size_of_it = size(the_list, 1);

    %Sort this list based on quads and then difference in 
    [sortedIt] = sortrows(the_list, [quad_index, diff_index]);
    
    %Get all the quads unique to this badboy
    quads_found = unique(sortedIt(:,quad_index));
    quad_mode = zeros((length(quads_found) - length(quad_skip)), 3);
    mode_val = zeros((length(quads_found) - length(quad_skip)), 1);
    quad_mode_index = 1;
    final_length = 0;
    
    %Find the frequency for each quad
    sindex = 1;
    eindex = 1;
    for quad=1 : length(quads_found)
        %Check to make sure that this is not one of the quads to skip
        if(isempty(find(quad_skip == quads_found(quad), 1)))
            %Find the index of the first element in this quad
            while(sindex <= size_of_it && sortedIt(sindex, quad_index) ~= quads_found(quad))
                sindex = sindex + 1;
            end
            if(sindex > size_of_it)
                sindex = size_of_it;
            end
            
            %find the index of the last element in this quad
            eindex = sindex;
            while(eindex <= size_of_it && sortedIt(eindex, quad_index) == quads_found(quad))
                eindex = eindex + 1;
            end
            if(eindex > size_of_it)
                eindex = size_of_it;
            end
            
            %Create a list of possible modes
            possible_modes = sort(unique(sortedIt(sindex:eindex, diff_index)));
            possible_frequencies = zeros(length(possible_modes), 1);
            biggest_mode = 0;
            biggest_mode_index = 0;
            
            %Find the frequency of each of the modes
            for i=1:length(possible_modes)
                possible_frequencies(i, 1) = length(find(sortedIt(sindex:eindex, diff_index) == possible_modes(i)));
                if(biggest_mode < possible_frequencies(i, 1))
                   biggest_mode = possible_frequencies(i, 1);
                   biggest_mode_index = i;
                end
            end
            
            %Calculate the most frequent change and get the points on either side of it
            quad_mode(quad_mode_index, 1) = quads_found(quad);
            quad_mode(quad_mode_index, 2) = possible_modes(biggest_mode_index, 1) - 2;
            quad_mode(quad_mode_index, 3) = possible_modes(biggest_mode_index, 1) + 3;
            mode_val(quad_mode_index, 1) = possible_modes(biggest_mode_index, 1);
            
            %Try to get the frequency of the length from one bin above the biggest
            final_length = final_length + length(find(sortedIt(sindex:eindex, diff_index) == quad_mode(quad_mode_index, 2)));
            
            %Get the frequency of the mode bin
            final_length = final_length + biggest_mode;

            %Get the frequency of the length from one bin below the biggest
            final_length = final_length + length(find(sortedIt(sindex:eindex, diff_index) == quad_mode(quad_mode_index, 3)));
            
            %Move to the next quad to check out
            quad_mode_index = quad_mode_index + 1;
            
            %Set the serach index as the end of the current set
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
        while(sindex <= size_of_it && sortedIt(sindex, quad_index) ~= quad_mode(quad, 1))
            sindex = sindex + 1;
        end
        if(sindex > size_of_it)
                sindex = size_of_it;
        end
        
        %Loop on each correlated point in this quad
        eindex = sindex;
        while(eindex <= size_of_it && sortedIt(eindex, quad_index) == quad_mode(quad, 1))
            change = sortedIt(eindex, diff_index);
            if (quad_mode(quad, 2) <= change)  && (change <= quad_mode(quad, 3))
                curcount = curcount + 1;
                combined(1, curcount) = int32(sortedIt(eindex, 4));
                combined(2, curcount) = int32(sortedIt(eindex, 5));
                combined(3, curcount) = int32(sortedIt(eindex, 6));
                combined(4, curcount) = int32(sortedIt(eindex, 7));
            end
            eindex = eindex + 1;
        end
        sindex = eindex;
    end
    
    %removed the ends that were not calculated
    if(curcount < final_length)
        for removeindex=1:(final_length - curcount)
            combined(:, final_length - removeindex) = [];
        end
        msg = (['Debug: curcount (', num2str(curcount),') != final_length (', num2str(final_length) ,') - remove empty cells => most_common.m']);
        disp(msg);
    end
    
    %Remove the ends that have not filled with anything
    removed = 0;
    while combined(1, curcount) == 0 && combined(2, curcount) == 0
        combined(:, curcount) = [];
        curcount=curcount-1;
        removed=removed+1;
    end
    if(removed>0)
        disp('Debug: removing end places becuase they only are zero for some reason');
    end
    
    %Find the reverse indexing to the original input list
    indexed = zeros(curcount, 1);
    not_found = 0;
    for count1=1:curcount
        found = 0;
        count2 = 1;
        while count2 <= size_of_it && found == 0
            if(the_list(count2, 4) == combined(1, count1) && ...
               the_list(count2, 5) == combined(2, count1) && ...
               the_list(count2, 6) == combined(3, count1) && ...
               the_list(count2, 7) == combined(4, count1))
                found = count2;
            end
            count2 = count2 + 1;        
        end
        if(found > 0)
            indexed(count1) = found;
        else
            not_found = not_found + 1;
        end
    end
    
    if(not_found > 0)
        disp(['Did not find: ', num2str(not_found)]);
    end
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
