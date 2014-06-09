function [points]  = get_box_coordinates(bwimg)
    %Find a box the encompasses all of the values in the optic disc region
    y1 = size(bwimg,1);
    y2 = 0;
    x1 = size(bwimg,2);
    x2 =  0;

    for y=1:size(bwimg,1)
        for x=1:size(bwimg,2)
            if bwimg(y,x) == 1
                if y < y1
                    y1 = y;
                end
                if y > y2
                    y2 = y;
                end
                if x < x1
                    x1 = x;
                end
                if x > x2
                    x2 = x;
                end
            end
        end
    end

    %Scale the x-axis to it is not so big
    ysub = round((y2 - y1) * .1);
    y1 = y1 + ysub;
    y2 = y2 - ysub;

    points = [y1 x1;...
              y1 x2;...
              y2 x2;...
              y2 x1;...
             ];
end