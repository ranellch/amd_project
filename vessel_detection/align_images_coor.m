function [pointsA, pointsB] = align_images_coor(img1, img2, quad_count, skip_quad)
    %Add the path for the Correlation Correspondance code
    addpath('crosscoor');
    
    %Convert the images to double and then normalize pixel intenstiy
    image1 = im2double(img1)/256;
    image2 = im2double(img2)/256;
    
    %Resize the image so that they are both the same now
    minx = size(image1, 2);
    miny = size(image1, 1);
    
    %Build string for output information
    skip = '';
    if(isempty(skip_quad) == false)
        skip = num2str(skip_quad(1));
        for i=2:length(skip_quad)
            disp(quad_count);
            skip = strcat(skip, ',', num2str(skip_quad(i)));
        end
    end
    disp(['Running Correlation: skip(', skip, ') Please Wait...(up to 5 Minutes)']);
    
    %Run Correlation Correspondance
    cc = correlCorresp('image1', image1, 'image2', image2);
    %Increase this value to decrease the number of featues
    cc.relThresh = 0.5;
    %Decrease this value to make the matches more precise
    %Decrease this value also increases time to run
    cc.convTol = 0.05;
    %Set value to 2 for more less strict reverse matching
    %Set value to 1 for more strict revserse matching
    cc.matchTol = 2;

    %Run the sliding crossCorr
    t = cputime;
    cc = cc.findCorresps;
    t = cputime - t;
    disp(['Correlation Time: ', num2str(t), ' seconds']);
                  
    %Get the most common points in each quad
    temp = most_common(cc.corresps, quad_count, skip_quad, minx, miny);
    
%     %Display the original set of matched points
%     figure(1);
%     correspDisplay(temp, image1);
%     %figure(2);
%     %correspDisplay(temp, image2);
    
    %Form arry in the correct manner
    pointsA = temp(1:2,:)';
    pointsB = temp(3:4,:)';
end
