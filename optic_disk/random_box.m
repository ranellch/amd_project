function [random_x_start, random_x_end, random_y_start, random_y_end] = random_box(maxx, maxy, min)
    away_from_edge = maxx / 12;

    random_x_start = randi(maxx, 1);
    if random_x_start + min >= maxx
        random_x_start = maxx - min;
    end
    random_x_end = random_x_start + min;

    if(random_x_end + away_from_edge > maxx)
        random_x_start = maxx - away_from_edge - min;
        random_x_end = random_x_start + min;
    end
    
    random_y_start = randi(maxy, 1);
    if random_y_start + min >= maxy
        random_y_start = maxy - min;
    end
    random_y_end = random_y_start + min;
    
    if(random_y_end + away_from_edge > maxy)
        random_y_start = maxy - away_from_edge - min;
        random_y_end = random_y_start + min;
    end
end
