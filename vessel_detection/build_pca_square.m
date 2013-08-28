function [out] = build_pca_square(pid)
    addpath('..');
    
    path = get_path(pid, '1');
    I = imread(['../Test Set/', path]);
    figure(1);
    imshow(I)
    rect = getrect;
        
    ycoord = round(rect(2));
    xcoord = round(rect(1));
    side_N = round(rect(4));
    disp(['Located at: ', num2str(xcoord), ', ', num2str(ycoord), ' with N=' num2str(side_N)]);
    
    window = zeros(side_N, side_N, 'uint8');
    next_y = 0;
    for y=1:side_N
        next_x = 0;
        for x=1:side_N
            if ((next_y + ycoord) > 0 && ...
               (next_y + ycoord) <= size(I, 1) && ...
               (next_x + xcoord) > 0 && ...
               (next_x + xcoord) <= size(I, 2))
                window(y, x) = I(next_y + ycoord, next_x + xcoord);
            end
            next_x = next_x + 1;
        end
        next_y = next_y + 1;
    end
    
    figure(2);
    imshow(window);
    
    rowvector = zeros(1, side_N * side_N, 'uint8');
    rowindex = 1;
    for y=1:side_N
        for x=1:side_N
            rowvector(rowindex) = window(y, x);
            rowindex = rowindex + 1;
        end
    end
    
    disp(rowvector);
        
    [COEFF,SCORE] = princomp(double(rowvector));
    disp(COEFF);
end
