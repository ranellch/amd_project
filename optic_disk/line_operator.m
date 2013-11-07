classdef line_operator
properties(GetAccess=private)
    len
    norien
    line_matricies
    degrees
    ready_to_go
end

methods
    function obj=line_operator(l, nor)
        %Error check the input values
        if(mod(l, 2) == 0)
            error('The length(l) must be odd for this to work');
        end
        if(nor <= 0)
            error('The number of orientations(norien) must be greater than 0');
        end
  
        %Get the line definition variables
        len = l;
        norien = nor;

        %Init the line_matricies variable
        line_matricies = zeros(len,len,norien);
        degress = zeros(len, 1);

        for theta=1:norien
            %Get the current degree orientation of the line
            deg = (theta / norien) * 180.0;

            %Get the line matrix and copy into list of line matricies
            sub_line_matrix = create_line(len, deg);
            for y=1:len
                for x=1:len
                    line_matricies(y,x,theta) = sub_line_matrix(y,x);
                end
            end

            degrees(theta, 1) = deg;
        end

        ready_to_go = 1;
    end

    function [fv] = get_fv(img, yin, xin)
        if(ready_to_go ~= 1)
            error('Class has not been initialized yet');
        end

        %Variables for output
        fv = zeros(1, 3);
        ed = floor(len / 2.0);

        %Get the average gray scale intensity within the square window over the xurrent pixel under investigation
        [square_sum, square_count] = iterate_mask(img, yin, xin, each_direction, ones(l));
        square_avg = square_sum / double(square_count);

        %Find line orientation with maximum line strength
        max_line_strength = 0.0;
        max_line_str_deg = 0.0;

        for theta=1:norien
            %Calculate the current line strength
            [line_sum, line_count] = iterate_mask(img, yin, xin, ed, line_matrcies(:,:,theta));
            line_avg = line_sum / double(line_count);
            current_line_strength = line_avg - square_avg;

            %Keep track of greatest line strength
            if(current_line_strength > max_line_strength)
                max_line_strength = current_line_strength;
                max_line_str_deg = degrees(theta, 1);
            end
        end

        %Get the line strength of the pixel perpendicular to the maximum line strength
        nindeg = max_line_str_deg + 90.0;
        ninlen = 3;
        nindeg_matrix = create_line(ninlen, nindeg);
        [nine_sum, nine_count] = iterate_mask(img, yin, xin, floor(ninlen / 2.0), nindeg_matrix);
        nine_avg = nine_sum / double(nine_count);
        nine_line_strength = nine_avg - square_avg;

        fv(1,1) = max_line_strength;
        fv(1,2) = nine_line_strength;
        fv(1,3) = img(yin,xin);
    end

    function [line_matrix] = create_line(length, angle)
       %Create a line with at least l points that are the value one
        line_matrix_temp = strel('line', length, angle).getnhood();
        next_size_up=1;
        while(size(line_matrix_temp, 1) < length && size(line_matrix_temp, 2) < length)
            line_matrix_temp = strel('line', length + next_size_up, angle).getnhood();
            next_size_up = next_size_up+1;
        end

        %Pad array becuase we will later extract a square that is lengthxlength
        ed = floor(length / 2.0);
        line_matrix = padarray(line_matrix_temp, [ed,ed], 'both');

        %Calculate the index of the center of the matrix
        middle_y = ceil(size(line_matrix, 1) / 2.0);
        middle_x = ceil(size(line_matrix, 2) / 2.0);

        %Get the subset martix
        line_matrix = line_matrix(middle_y-ed:middle_y+ed, middle_x-ed:middle_x+ed);
    end

    function [sumval, count] = iterate_mask(img, yin, xin, each_direction, matrix_in)
        %Initialize variables for summation and counting
        sumval = 0.0;
        count = 0;

        start_y = 0;
        for y = yin - each_direction:yin + each_direction
            start_y = start_y + 1;
            start_x = 0;
            for x = xin - each_direction:xin + each_direction
                start_x = start_x + 1;
                if(y >= 1 && y<=size(img, 1) && x >= 1 && x <= size(img, 2))
                    if(matrix_in(start_y, start_x) == 1)
                        count = count + 1;
                        sumval = sumval + double(img(y, x));
                    end
                end
            end
        end
    end
   
 
end

end

function [feature_vector] = line_operator(img, yin, xin, l, norien)
    %Error check the input values
    if(mod(l, 2) == 0)
        error('The length(l) must be odd for this to work');
    end
    if(norien <= 0)
        error('The number of orientations(norien) must be greater than 0');
    end

    feature_vector = zeros(1, 3);
    each_direction = floor(l / 2.0);

    %Get the average gray scale intensity within the square window over the xurrent pixel under investigation
    [square_sum, square_count] = iterate_mask(img, yin, xin, each_direction, ones(l));
    square_avg = square_sum / double(square_count);

    %Find line orientation with maximum line strength
    max_line_strength = 0.0;
    max_line_str_deg = 0.0;
    
    for theta=1:norien
        %Get the current degree orientation of the line
        deg = (theta / norien) * 180.0;

        %Create a line matrix that is lengthxlength
        sub_line_matrix = create_line(l, deg);

        %Count the number of values in the line
        sub_line_sum = 0;
        for y=1:size(sub_line_matrix,1)
            for x=1:size(sub_line_matrix,2)
                if(sub_line_matrix(y,x) == 1)
                   sub_line_sum=sub_line_sum+1;
                end
            end
        end

        if(sub_line_sum ~= l)
            error([num2str(sub_line_sum), ' ~= ', num2str(l)]);
        end

        %Calculate the current line strength       
        [line_sum, line_count] = iterate_mask(img, yin, xin, each_direction, sub_line_matrix);
        line_avg = line_sum / double(line_count);
        current_line_strength = line_avg - square_avg;

        %Keep track of greatest line strength
        if(current_line_strength > max_line_strength)
            max_line_strength = current_line_strength;
            max_line_str_deg = deg;
        end
    end

    %Get the line strength of the pixel perpendicular to the maximum line strength
    nindeg = max_line_str_deg + 90.0;
    ninlen = 3;
    nindeg_matrix = create_line(ninlen, nindeg);
    [nine_sum, nine_count] = iterate_mask(img, yin, xin, floor(ninlen / 2.0), nindeg_matrix);
    nine_avg = nine_sum / double(nine_count);
    nine_line_strength = nine_avg - square_avg;

    feature_vector(1,1) = max_line_strength;
    feature_vector(1,2) = nine_line_strength;
    feature_vector(1,3) = img(yin,xin);
end

function [line_matrix] = create_line(length, angle)
    %Create a line with at least l points that are the value one
    line_matrix_temp = strel('line', length, angle).getnhood();
    next_size_up=1;
    while(size(line_matrix_temp, 1) < length && size(line_matrix_temp, 2) < length)
        line_matrix_temp = strel('line', length + next_size_up, angle).getnhood();
        next_size_up = next_size_up+1;
    end

    %Pad array becuase we will later extract a square that is lengthxlength
    ed = floor(length / 2.0);
    line_matrix = padarray(line_matrix_temp, [ed,ed], 'both');

    %Calculate the index of the center of the matrix
    middle_y = ceil(size(line_matrix, 1) / 2.0);
    middle_x = ceil(size(line_matrix, 2) / 2.0);

    %Get the subset martix
    line_matrix = line_matrix(middle_y-ed:middle_y+ed, middle_x-ed:middle_x+ed);
end

function [sumval, count] = iterate_mask(img, yin, xin, each_direction, matrix_in)
    %Initialize variables for summation and counting
    sumval = 0.0;
    count = 0;

    start_y = 0;
    for y = yin - each_direction:yin + each_direction
        start_y = start_y + 1;
        start_x = 0;
        for x = xin - each_direction:xin + each_direction
            start_x = start_x + 1;
            if(y >= 1 && y<=size(img, 1) && x >= 1 && x <= size(img, 2))
                if(matrix_in(start_y, start_x) == 1)
                    count = count + 1;
                    sumval = sumval + double(img(y, x));
                end
            end
        end
    end
end
