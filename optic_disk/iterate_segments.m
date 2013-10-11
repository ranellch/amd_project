function [x,y] = iterate_segments(img, snaked_img, shift, debug)
%Gets the bin values in decsending order of magnitude
bins=sort(unique(shift));

%Get the image to hold binary data
iout=im2bw(zeros(size(shift)));

for b=1:length(bins)    
    %This img is for visualization purposes only
    rgbImage = cat(3, img, img, img);
    
    %Get only three clustered regions of intenstiy at a time
    for ycor=1:size(shift, 1)
        for xcor=1:size(shift,2)
            if(shift(ycor,xcor) == bins(b))
                iout(ycor, xcor) = 1;
                rgbImage(ycor,xcor,2) = 100;
            else
                iout(ycor, xcor) = 0;
            end
        end
    end

    %Get the subimage around 
    if(debug == 1)
        figure(1), imshow(rgbImage);
    end
    
    %Find the number of connected regions and their centroids
    CC=bwconncomp(iout);
    S=regionprops(CC,'Centroid');

    %build a window to do more refiend segmentation
    wind = size(img, 1) / 3;
    
    %Get the centroids for each one of these bad boys
    for i=1:length(S)
        x=S(i).Centroid(1);
        y=S(i).Centroid(2);

        sx = round(x - (wind / 2));
        ex = sx + wind;
        if(sx <= 0) 
            sx = 1;
        end
        if(ex > size(img, 2))
            ex = size(img, 2);
        end

        sy = round(y - (wind / 2));
        ey = sy + wind;
        if(sy <= 0)
            sy = 1;
        end
        if(ey > size(img, 1))
            ey = size(img, 1);
        end
        
        %Get the subimage
        subimage = img(sy:ey,sx:ex);
        
        %Get the snaked img and see if optic disk is in this window
        subimg_snake = snaked_img(sy:ey,sx:ex);
        
        %Get the sum of the snake img
        sum=0;
        for y=1:size(subimg_snake,1)
            for x=1:size(subimg_snake,2)
                if(subimg_snake(y,x) > 0)
                    sum=sum+1;
                end
            end
        end
        
        percentage_disk = sum / (size(subimg_snake,1) * size(subimg_snake,2));
        if(debug == 1)
            figure(2),imshow(subimage);
        end
        if(percentage_disk ~= 0)
            disp(['Checked: ', num2str(b), '/', num2str(length(bins)), ' with ', num2str(percentage_disk * 100), '% of the image!']);
        end
    end
end
end