function [ data ] = compare_maculas(varargin)
% Process Image

    % Create a struct for the curve data
    data = struct(...
                  'Trial', '', ...    
                  'HPRS', [], ...
                  'HPOS', [], ...
                  'MAQ',  [] ...
                 );

     p = struct('fovea1', [0 0], 'optic1', [0 0], 'fovea2', [0 0], 'optic2', [0 0], 'bifurs1', [], 'bifurs2', []);
     if ~isempty(varargin) || length(varargin) ~=4
         disp('Invalid arguments entered');
         return
     end
     
     %~~~Get image 1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    if isempty(varargin) %if runtest has not been called, prompt user for files
        % If an images directory exists, look there first
        path = set_path('./Images/','*.tif');

        % Open dialog box to select file
        [filename1,path1] = uigetfile(path, 'Select Image to Process');
        if isequal(filename1,0) || isequal(path1,0)
           disp('User pressed cancel')
           return
        else
           disp(['User selected ', fullfile(path1, filename1)])
        end
        fullpath = fullfile(path1,filename1);

    
    else %read from xml if runtest has been called
       
        visit1 = varargin{1};
        visit2 = varargin{2};
        patid = varargin{3};
        trialname = varargin{4};
        
        filename1 = visit1;
        filename2 = visit2;
        
        fullpath = fullfile('./Test Set/', visit1);
       
        xDoc= xmlread('images.xml');
        images = xDoc.getElementsByTagName('image');

        % Get coordinates of fovea and macula from xml
         for count = 1:images.getLength  
            image = images.item(count - 1);
            %Find specified
            path = char(image.getAttribute('path'));
            if all(strcmpi(path, visit1))
                p.optic1(1) = str2double(char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent));
                p.optic1(2) = str2double(char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent));
                p.fovea1(1) = str2double(char(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent));
                p.fovea1(2) = str2double(char(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent));
            end
         end
         data.Trial = strcat(patid, trialname);
     end
    
    % Read the image
        imgRGB=imread(fullpath);
        RGB_test=size(size(imgRGB));
        if(RGB_test(2)==3)
            img1=rgb2gray(imgRGB);
        else
            img1=imgRGB;
        end
    % Crop footer
    img1 = crop_footer(img1);
    % Store the size/dimensions of the image
    img_sz1 = size(img1);
         

    
    
    %~~~Get second image~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if isempty(varargin) %if runtest has not been called, prompt user for files
        % If an images directory exists, look there first
        path = set_path('./Images/','*.tif');

        % Open dialog box to select file
        [filename2,path2] = uigetfile(path, 'Select Image to Compare');
         if isequal(filename2,0) || isequal(path2,0)
           disp('User pressed cancel')
           return
        else
           disp(['User selected ', fullfile(path2, filename2)])
        end
        fullpath = fullfile(path2,filename2);
    else
        fullpath = fullfile('./Test Set/', visit2);

        xDoc= xmlread('images.xml');
        images = xDoc.getElementsByTagName('image');

        % Get coordinates of fovea and macula from xml
         for count = 1:images.getLength  
            image = images.item(count - 1);
            %Get the filename from the image tag
            path = char(image.getAttribute('path'));
            if all(strcmpi(path, visit2))
                p.optic2(1) = str2double(char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent));
                p.optic2(2) = str2double(char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent));
                p.fovea2(1) = str2double(char(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent));
                p.fovea2(2) = str2double(char(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent));
            end
         end
    end
     

    
      % Read the image
    imgRGB=imread(fullpath);
    RGB_test=size(size(imgRGB));
    if(RGB_test(2)==3)
        img2=rgb2gray(imgRGB);
    else
        img2=imgRGB;
    end
    
    % Crop footer
    img2 = crop_footer(img2);
    
     % Store the size of the image
    img_sz2 = size(img2);
        
    

  %~~~~~~~~% Ask for input points~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    figure('Name', 'Selected Images');
    subplot(1,2,1); imshow(img1)
    title(filename1)
    subplot(1,2,2); imshow(img2)
    title(filename2)
    p = struct('fovea1', [], 'optic_disk1', [], 'bifurs', [], 'bifurs', [], 'fovea2', [], 'optic_disk2', [];
    disp('Select fovea on current visit')
    p.fovea1 = round(ginput(1));
    disp('Select optic disk on current visit')
    p.optic_disk1 = round(ginput(1));
    disp('Select bifurcation point 1 on current visit')
    p.bifur1 = round(ginput(1));
    disp('Select same bifurcation point 1 on previous visit')
    p.bifur2 = round(ginput(1));
   
    %~~~~~~~~~~~Image Processing~~~~~~~~~~~~~~~~~~~ 
    
    % Run gaussian filter
     r1 = round(10/770*img_sz1(1)); %scale filter size---10 by 10 pixs for 768 by 770 res (standard res - footer)
     c1 = round(10/768*img_sz1(2));
     
     H = fspecial('gaussian', [r1 c1], 5);
     proc1=imfilter(img1,H);
    
     r2 = round(10/770*img_sz2(1)); %scale filter size---10 by 10 pixs for 768 by 770 res (standard res - footer)
     c2 = round(10/768*img_sz2(2));
     
     H = fspecial('gaussian', [r2 c2], 5);
     proc2=imfilter(img2,H);
    
    %Scale intensity of img2 to img1
     proc2 = scale_intensities(proc1, p.fovea1, p.optic_disk1, proc2, p.fovea2, p.optic_disk2);
    
     % Adjust contrasts/center pix distriution on mean intensity of ring between
     % macula and optic disk
     
     % create ring mask
     [xgrd1, ygrd1] = meshgrid(1:img_sz1(2), 1:img_sz1(1));   
      x1 = xgrd1 - p.fovea1(1);    % offset the origin
      y1 = ygrd1 - p.fovea1(2);
     ro= sqrt((p.optic_disk1(1)-p.fovea1(1))^2+(p.optic_disk1(2)-p.fovea1(2))^2);
     ri = sqrt((p.optic_disk1(1)-p.fovea1(1))^2+(p.optic_disk1(2)-p.fovea1(2))^2)*.5;
     ob = x1.^2 + y1.^2 <= ro.^2; %outer bound   
     ib = x1.^2 + y1.^2 >= ri.^2; %inner bound
     ring = logical(ib.*ob);
      rep1 = mean(proc1(ring));
      if rep1 < 64
          gamma1 = 0.5;
      elseif rep1 >= 64 && rep1 < 96
          gamma1 = 0.75;
      elseif rep1 >=96 && rep1 < 160
          gamma1 = 1.0;
      elseif rep1 >= 160 && rep1 < 192
          gamma1 = 1.25;
      elseif rep1 >=192
          gamma1 = 1.5;
      end

      
       proc1 = imadjust(proc1,[],[],gamma1);

       
      [xgrd2, ygrd2] = meshgrid(1:img_sz2(2), 1:img_sz2(1));   
      x2 = xgrd2 - p.fovea2(1);    % offset the origin
      y2 = ygrd2- p.fovea2(2);
      ro= sqrt((p.optic_disk2(1)-p.fovea2(1))^2+(p.optic_disk2(2)-p.fovea2(2))^2);
      ri = sqrt((p.optic_disk2(1)-p.fovea2(1))^2+(p.optic_disk2(2)-p.fovea2(2))^2)*.5;
      ob = x2.^2 + y2.^2 <= ro.^2; %outer bound   
      ib = x2.^2 + y2.^2 >= ri.^2; %inner bound
      ring = logical(ib.*ob);
       rep2 = mean(proc2(ring));
      if rep2 < 64
          gamma2 = 0.5;
      elseif rep2 >= 64 && rep1 < 96
          gamma2 = 0.75;
      elseif rep2 >=96 && rep1 < 160
          gamma2 = 1.0;
      elseif rep2 >= 160 && rep1 < 192
          gamma2 = 1.25;
      elseif rep2 >=192
          gamma2 = 1.5;
      end
      

      
      proc2 = imadjust(proc2,[],[],gamma2);

      
    % Create a figure for the images before and after processing
    if isempty(varargin)
        figure('Name','Processing Results');
        subplot(2,2,1);
        imshow(img1); title(strcat('Original', filename1));
        subplot(2,2,2);
        imshow(proc1); title(strcat('Processed', filename1));
        subplot(2,2,3);
        imshow(img2); title(strcat('Original', filename2));
        subplot(2,2,4);
        imshow(proc2); title(strcat('Processed', filename2));
    else
        h = figure('Name','Processing Results','visible','off');
        subplot(2,2,1);
        imshow(img1); title(strcat('Original', filename1));
        subplot(2,2,2);
        imshow(proc1); title(strcat('Processed', filename1));
        subplot(2,2,3);
        imshow(img2); title(strcat('Original', filename2));
        subplot(2,2,4);
        imshow(proc2); title(strcat('Processed', filename2));
        data_filename = strcat('./Output Images/', patid, '/', data.Trial);
        saveas(h, strcat(data_filename, '-processing'),'png');
    end
    
       
%     %~~~~~~~~Determine Thresholds for MAQ calculation~~~~~~~~~~~
%     % Create circle mask to ignore macula
%     r=sqrt((p.optic_disk1(1)-p.fovea1(1))^2+(p.optic_disk1(2)-p.fovea1(2))^2)/2;
%     circlemask = x1.^2 + y1.^2 <= r.^2;
%     
%     % Get standard deviation of pixel inensity outside macula for img1
%     periph = double(proc1(~circlemask));
%     hypr_thrsh = 1*std(periph(:));
%     hypo_thrsh = -1*std(periph(:));

   %~~~~~~~~~~~~~~Analyze Maculas~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
   %Create macular window 1
       lbound = p.fovea1(1) - round(abs(p.fovea1(1) - p.optic_disk1(1))*.5);
       rbound = p.fovea1(1) + round(abs(p.fovea1(1) - p.optic_disk1(1))*.5);
       if lbound < 1
           lbound = 1;
       end
       if rbound > img_sz1(2)
           rbound = img_sz1(2);
       end
       width = lbound : rbound;
      
       bbound = p.fovea1(2) + round(abs(p.fovea1(1) - p.optic_disk1(1))*.5);
       tbound = p.fovea1(2) - round(abs(p.fovea1(1) - p.optic_disk1(1))*.5);
       if tbound < 1 
           tbound = 1;
       end
       if bbound > img_sz1(1)
           bbound = img_sz1(1);
       end
       height =  tbound : bbound;

   win1 = proc1(height,width);
   sz1 = size(win1);
  
    %Create macular window 2
       lbound = p.fovea2(1) - round(abs(p.fovea2(1) - p.optic_disk2(1))*.5);
       rbound = p.fovea2(1) + round(abs(p.fovea2(1) - p.optic_disk2(1))*.5);
       if lbound < 1
           lbound = 1;
       end
       if rbound > img_sz2(2)
           rbound = img_sz2(2);
       end
       width = lbound : rbound;
      
       bbound = p.fovea2(2) + round(abs(p.fovea2(1) - p.optic_disk2(1))*.5);
       tbound = p.fovea2(2) - round(abs(p.fovea2(1) - p.optic_disk2(1))*.5);
       if tbound < 1 
           tbound = 1;
       end
       if bbound > img_sz2(1)
           bbound = img_sz2(1);
       end
       height =  tbound : bbound;

       win2 = proc2(height,width);
       sz2 = size(win2);
%        
%        win2= contrast_stretch(win2, mean2(win2), 2);
%        win1 = contrast_stretch(win1,mean2(win1),2);
       

    %Call Nate's function

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~       
     % Show maculas
    figure('Name', 'Areas of Interest');
    subplot(1,2,1);
    colormap(gray), imagesc(win2); 
    subplot(1,2,2);
    colormap(gray), imagesc(win1);
    
    % Show surfaces
    figure('Name', '3D Surfaces');
    subplot(1,2,1);   
    surf(fliplr(double(win2)),'EdgeColor', 'none'); 
    title(strcat('Previous Visit: ',filename2)); 
    view(153, 78);
    subplot(1,2,2);
    surf(fliplr(double(win1)),'EdgeColor', 'none');   
    title(strcat('Current Visit:',filename1));
    view(153, 78);
    
   
    %~~~~Show Disease Progress~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
      
    figure('Name', 'Macular Comparison');
    subplot(2,2,1);
    imshow(win2); title('Previous Visit');
    subplot(2,2,2);
   imshow(win1); title('Current Visit');
    subplot(2,2,3);
    imshow(win1); title('Progression');
    h5=gca;

    
    %Calculate MAQ
    win_avg1 = zeros(50,50);
    win_avg2 = zeros(50,50);
    xln1 = sz1(2)/50; %create 50 by 50 grid
    yln1 = sz1(1)/50;
    xln2 = sz2(2)/50;
    yln2 = sz2(1)/50;
    m=1;
    for i = 1:yln1:sz1(1)-yln1+1
        k=1; 
         for j = 1:xln1:sz1(2)-xln1+1
            bloc = win1(round(i):round(i+yln1)-1, round(j):round(j+xln1)-1);
            win_avg1(m,k)  = mean2(bloc);
            k=k+1;
        end
        m=m+1;
    end
       m=1;
    for i = 1:yln2:sz2(1)-yln2+1
        k=1; 
         for j = 1:xln2:sz2(2)-xln2+1
            bloc = win2(round(i):round(i+yln2)-1, round(j):round(j+xln2)-1);
            win_avg2(m,k)  = mean2(bloc);
            k=k+1;
        end
        m=m+1;
    end
    
    DWB = win_avg1 - win_avg2;
    data.HPOS = sum(sum(DWB(DWB<0)));
    data.HPRS = sum(sum(DWB(DWB>0)));
    data.MAQ = sum(sum(DWB));
    
    hypr_thrsh = std(DWB(:))
    hypo_thrsh = -std(DWB(:))       
    
     %Show gridlines for MAQ calculation
    hold(h5);
    for k = 0.5:yln1:sz1(1)-rem(sz1(1),yln1)+0.5
    x = [0.5 sz1(2)+0.5];
    y = [k k];
    plot(h5,x,y,'Color','k','LineStyle','-');
    end

    for k = 0.5:xln1:sz1(2)-rem(sz1(2),xln1)+0.5
    x = [k k];
    y = [0.5 sz1(1)+0.5];
    plot(h5,x,y,'Color','k','LineStyle','-');
    end
    hold off
    
    %~~~~~~~Show changes in hypo/hyper regions~~~~~~~~~~~~~~~~~~~~~~~~~
    
    redx=ones(4,250);
    yellx=ones(4,250);
    redy=ones(4,250);
    yelly=ones(4,250);
 
    
    m = 1; 
    p1 = 1;
    p2 = 1;
    for i = 0.5:yln1:sz1(1)-rem(sz1(1),yln1)-yln1+0.5
        k=1;
        for j = 0.5:xln1:sz1(2)-rem(sz1(2),xln1)-xln1+0.5
         if DWB(m,k) > hypr_thrsh
            yelly(:,p1) = [i;i;i+yln1;i+yln1]; %specify vertices of patches
            yellx(:,p1) = [j;j+xln1;j+xln1;j];
            p1=p1+1;
         elseif DWB(m,k) < hypo_thrsh
            redy(:,p2) = [i;i;i+yln1;i+yln1];
            redx(:,p2) = [j;j+xln1;j+xln1;j];
            p2=p2+1;
         end
         k=k+1;
        end
        m=m+1;
    end

 
   % Remove zeros  
        redx = reshape(redx(redx~=1),4,[]);
        yellx = reshape(yellx(yellx~=1),4,[]);
        redy=reshape(redy(redy~=1),4,[]);
        yelly=reshape(yelly(yelly~=1),4,[]);

   % Fill patches
        hold(h5);
        alpha(patch(redx,redy,'r'),.5); 
        alpha(patch(yellx,yelly,'y'),.5);
        hold off
  
        set(h5, 'Position', [0.27 0.02000 1.5*0.3347 1.5*0.3338]); % Increase size of progression image
        
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
    fprintf('Results: \n');
    disp(data);
    
    
%     % If a data directory exists, start there to save
%     path = set_path('Data','');
% 
%     % Open dialog box to save the data in the Data directory
%     data_filename = fullfile(path, strrep(filename1,'.tif','.mat'));
%     
%     % Store the surfaces into our structure
%     data.surf_new = surf_new;
%     data.surf_old = surf_old;
%     
%     % Save the structure under the filename data_filename
%     save(data_filename,'data');
%     fprintf('Processed Image Data Saved As: \n%s\n', data_filename);


end
