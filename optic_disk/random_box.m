function [random_x_start, random_x_end, random_y_start, random_y_end] = random_box(maxx, maxy, min)
    random_x_start = randi(maxx, 1);
    if random_x_start + min >= maxx
        random_x_start = maxx - min;
    end
    random_x_end = random_x_start + min;

    random_y_start = randi(maxy, 1);
    if random_y_start + min >= maxy
        random_y_start = maxy - min;
    end
    random_y_end = random_y_start + min;
end
