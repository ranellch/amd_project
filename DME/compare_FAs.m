function [ Iout, pixcount ] = compare_FAs(path1,path2,patid)
% REQUIRES: Registered image paths entered in the order: EARLY,LATE,
% patient/image id 
% EFFECTS: Returns highlighted leakage, and a pixelcount of leakage area
% Uses get_background

 
 
     
      % Read the first image
    imgRGB=imread(path1);
    RGB_test=size(size(imgRGB));
    if(RGB_test(2)==3)
        img1=rgb2gray(imgRGB);
    else
        img1=imgRGB;
    end
    
    
    % Read the second image
    imgRGB=imread(path2);
    RGB_test=size(size(imgRGB));
    if(RGB_test(2)==3)
        img2=rgb2gray(imgRGB);
    else
        img2=imgRGB;
    end


             output_dir = strcat('./Output Images/', patid);
             if exist(output_dir, 'dir') == false
                mkdir(output_dir); 
             end
             
         data_filename = strcat(output_dir, '/', patid);
    

         
    %~~~~~~~~~~~Image Processing~~~~~~~~~~~~~~~~~~~ 
    %Gaussian smoothing
    H = fspecial('gaussian',[5 5],1.0);
    smooth1 = mat2gray(imfilter(double(img1),H));
    smooth2 = mat2gray(imfilter(double(img2),H));
     
       %Get normalized image maps in terms of standard deviations away from
       %background
       
       %get background binary maps
        background1 = getbackground(smooth1,0.7);
        background2 = getbackground(smooth2,0.7);
        
      %Create a figure for the segmented backgrounds
        h = figure('Name','Backgrounds','visible','off');
        subplot(1,2,1);
        imshow(background1); title('Background of Image 1');
        subplot(1,2,2);
        imshow(background2); title('Background Image 2');
        saveas(h, strcat(data_filename, '-backgrounds'),'png');
        close(h)  
        
        I1 = smooth1(background1);
        I2 = smooth2(background2);

        %Subtract mean of background pixels, and divide by standard
        %deviation of background to get "distances" away from
        %insignificance
        dists1 = (smooth1 - mean(I1))./std(I1);
        dists2 = (smooth2 - mean(I2))./std(I2);
      
        %Get binary maps showing areas in each image at least 1.5 standard
        %deviations above background mean
        sig_dists1 = dists1>1.5;
        sig_dists2 = dists2>1.5;
        
        %Create single binary mask of difference between previous two images
        init_estimate = sig_dists2;
        init_estimate(sig_dists2==sig_dists1)=false;
        init_estimate = imfill(init_estimate,'holes'); %fill holes
        
        %Create a figure showing highlighted areas of significance
        %in second image
        [Iind,map] = gray2ind(smooth2,256);
        Irgb=ind2rgb(Iind,map);
        Ihsv = rgb2hsv(Irgb);
        hueImage = Ihsv(:,:,1);
        hueImage(init_estimate) = 0.011; %red
        Ihsv(:,:,1) = hueImage;
        satImage = Ihsv(:,:,2);
        satImage(init_estimate) = .8; %semi transparent
        Ihsv(:,:,2) = satImage;
        Irgb = hsv2rgb(Ihsv);
        

        h = figure('Name','Initial Areas of Interest','visible','off');
        imshow(Irgb); title('Initial Areas of Interest');
        saveas(h, strcat(data_filename, '-initial estimate'),'png');
        close(h)
        
      %Run K-means Clustering on Intensity and Gabor images of original late stage image (after gaussian filter) 
      %Choose 12 clusters
      
      [Iseg, Icenters, centers] = gabor_intensity_cluster(smooth2, 12);
      
        h = figure('Name','Segmentation','visible','off');
        imshow(Iseg); colormap(jet); title('Segmentation');
        saveas(h, strcat(data_filename, '-segmentation'),'png');
        close(h)
      
      %Generate binary image showing brightest six clusters
      int_centers = centers(:,19);
      int_centers = sort(int_centers,'descend');
      
      brightest = zeros(size(Icenters));
      for i = 1:6
        brightest(Icenters==int_centers(i))=1;
      end
      brightest=logical(brightest);
      
        %Create a figure showing highlighted areas of significance
        %in second image based on texture and intensity segmentation
        [Iind,map] = gray2ind(smooth2,256);
        Irgb=ind2rgb(Iind,map);
        Ihsv = rgb2hsv(Irgb);
        hueImage = Ihsv(:,:,1);
        hueImage(brightest) = 0.011; %red
        Ihsv(:,:,1) = hueImage;
        satImage = Ihsv(:,:,2);
        satImage(brightest) = .8; %semi transparent
        Ihsv(:,:,2) = satImage;
        Irgb = hsv2rgb(Ihsv);
        
        h = figure('Name','Texture Areas of Interest','visible','off');
        imshow(Irgb); title('Texture Based Estimate');
        saveas(h, strcat(data_filename, '-texture based estimate'),'png');
        close(h)
      
      
      %Compare to initial estimate, keep regions that overlap in final binary mask 
      
      leaks = brightest & init_estimate;
      pixcount = nnz(leaks); %get pixel count
      
      %Create final figure showing highlighted leaks
      
        [Iind,map] = gray2ind(smooth2,256);
        Irgb=ind2rgb(Iind,map);
        Ihsv = rgb2hsv(Irgb);
        hueImage = Ihsv(:,:,1);
        hueImage(leaks) = 0.011; %red
        Ihsv(:,:,1) = hueImage;
        satImage = Ihsv(:,:,2);
        satImage(leaks) = .8; %semi transparent
        Ihsv(:,:,2) = satImage;
        Irgb = hsv2rgb(Ihsv);

    h = figure('Name', 'Retina Comparison','visible','off');
    subplot(2,2,1);
    imshow(smooth1); title('Early Image');
    subplot(2,2,2);
    imshow(smooth2); title('Later Image');
    subplot(2,2,3);
    imshow(Irgb); title('DME Leakage');
    h2=gca;
    set(h2, 'Position', [0.27 0.02000 1.5*0.3347 1.5*0.3338]);
    saveas(h, strcat(data_filename, '-leakage'),'png');
    close(h)
    
    Iout = leaks;
    

end
