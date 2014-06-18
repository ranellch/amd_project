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

    function [str, delta_str, ortho_str, mx_ang]=get_line_strengths(obj, img)
        if(obj.ready_to_go ~= 1)
            error('Before calling this method you must init(length, norien) the class!');
        end
        
        %Get the average gray scale intensity within a square window over
        %every pixel
        square_avg = imfilter(img, ones(obj.len)/(obj.len*obj.len), 'symmetric');
        

        %Run lineops
        all_line_strengths = zeros([size(img), obj.norien]);
        ortho_line_strengths = zeros([size(img), obj.norien]);

        %Get long line strengths for all orientations
        for theta=1:obj.norien
            all_line_strengths(:,:,theta) = imfilter(img, obj.line_matricies(:,:,theta)/obj.len,'symmetric') - square_avg;
        end
        
        %Get ortho line strengths for all orginal orientations
        for theta=1:obj.norien
            ortho_line_strengths(:,:,theta) = imfilter(img, create_line(3,obj.degrees(theta)+90.0)/3, 'symmetric') - square_avg;
        end
                
        %Find maximum line strength, angle of max, normalized difference between max and min line strength, and ortho line strength for every pixel
        [max_line_strength, max_thetas] = max(all_line_strengths,[],3); 
        min_line_strength = min(all_line_strengths,[],3);
        str = max_line_strength;
        delta_str = str - min_line_strength;
        mx_ang = zeros(size(img));
        ortho_str = zeros(size(img));
        for y = 1:size(img,1)
            for x = 1:size(img,2)
                mx_ang(y,x) = obj.degrees(max_thetas(y,x));
                ortho_str(y,x) = ortho_line_strengths(y,x,max_thetas(y,x));
            end
        end
        
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

