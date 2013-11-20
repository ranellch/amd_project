function [new_img, change_count] = x_neighbor(img, neighbor_cutoff)
    new_img = img;
    change_count = 0;
    for y=2:size(img,1)-1
        for x=2:size(img,2)-1
            if(img(y,x) == 0)
                %Count the number of neighbors that are white
                neighbor_count = 0;
                for y1=y-1:y+1
                    for x1=x-1:x+1
                        if(img(y1,x1) == 1)
                            neighbor_count=neighbor_count+1;
                        end
                    end
                end
                
                %If neighbor count is above cutoff then change current pixel to white
                if(neighbor_count > neighbor_cutoff)
                    new_img(x,y) = 1;
                    change_count=change_count+1;
                end
            end
        end
    end
end