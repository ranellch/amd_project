function [vertex] = find_parabola(bimg)
    %Get the skeleton of the image
    skel = bwmorph(bimg, 'thin', Inf);

    %Build line matricies to test
    the_matricies = create_matricies();
    
    %Iterate over each pixel
    for y=1:size(skel, 1)
        for x=1:size(skel, 2)
            %Find only the pixels that are considered vessels
            if(skel(y,x) == 1)
                for cur_angle=1:size(the_matricies, 3)
                    
                end
            end
        end
    end
end
