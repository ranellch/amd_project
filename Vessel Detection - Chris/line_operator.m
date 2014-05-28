classdef line_operator

properties
    len
    norien
    line_matricies
    degrees
    ready_to_go
end

methods
    function obj=line_operator(l, nor)
        obj.ready_to_go = 0;
        obj = obj.init(l, nor);
    end
end

methods
    function obj=init(obj, l, nor)
        %Error check the input values
        if(mod(l, 2) == 0)
            error('The length(l) must be odd for this to work');
        end
        if(nor <= 0)
            error('The number of orientations(norien) must be greater than 0');
        end
  
        obj.len = l;
        obj.norien = nor;

        %Init the line_matricies variable
        obj.line_matricies = zeros(obj.len,obj.len,obj.norien);
        obj.degrees = zeros(obj.norien, 1);

        for theta=1:obj.norien
            %Get the current degree orientation of the line
            deg = ((theta / obj.norien) * 180.0);

            %Get the line matrix and copy into list of line matricies
            sub_line_matrix = create_line(obj.len, deg);
            for y=1:obj.len
                for x=1:obj.len
                    obj.line_matricies(y,x,theta) = sub_line_matrix(y,x);
                end
            end
            
            obj.degrees(theta, 1) = deg;
        end

        obj.ready_to_go = 1;
    end

    function [str, mx_ang, square_avg]=get_strength_img(obj, img)
        if(obj.ready_to_go ~= 1)
            error('Before calling this method you must init(length, norien) the class!');
        end
        
        %Get the average gray scale intensity within a square window over
        %every pixel
        square_avg = imfilter(img, ones(obj.len)/(obj.len*obj.len), 'symmetric');

        %Find line orientation with maximum line strength
        all_line_strengths = zeros([size(img), obj.norien]);

        %Get line strengths for all orientations
        for theta=1:obj.norien
            all_line_strengths(:,:,theta) = imfilter(img, obj.line_matricies(:,:,theta)/obj.len,'symmetric') - square_avg;
        end
        
        %Find maximum for every pixel
        [max_line_strength, max_thetas] = max(all_line_strengths,[],3); 
        str = max_line_strength;
        mx_ang = zeros(size(img));
        for y = 1:size(img,1)
            for x = 1:size(img,2)
                mx_ang(y,x) = obj.degrees(max_thetas(y,x));
            end
        end

    end

    function ortho_str = get_ortho_str(obj, img, mx_ang, square_avg, yin, xin)
        %Calculate strength along line orthogonal to max line at (y, x)
        nindeg = mx_ang + 90.0;
        ninlen = 3;
        nindeg_matrix = create_line(ninlen, nindeg);
        [nine_sum, nine_count] = iterate_mask(img, yin, xin, floor(ninlen / 2.0), nindeg_matrix);
        nine_avg = nine_sum / double(nine_count);
        ortho_str = nine_avg - square_avg;

        end
    end
end

%Helper functions
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

