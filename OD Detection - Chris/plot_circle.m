function circle_img = plot_circle(xc,yc,R, max_x, max_y)
circle_img = zeros(max_y,max_x);
for y  = 1:max_y
    for x = 1:max_x
        if (x-xc)^2+(y-yc)^2 < R^2
            circle_img(y,x) = 1; 
        end
    end
end
end