function [ data ] = compare_maculas_seg(type, varargin)
% Process Image
    %type = 'FA' or 'AF'

    % Create a struct for the curve data
    data = struct(...
                  'Trial', '', ...    
                  'HYPR', [], ...
                  'HYPO', [], ...
                  'MAQ',  [] ...
                 );

 
     p = struct('fovea', [0 0], 'optic', [0 0]);
     if ~isempty(varargin) && length(varargin) ~=4
         disp('Invalid arguments entered');
         return
     end
     
     test = ~isempty(varargin);
     if test
        visit1 = varargin{1};
        visit2 = varargin{2};
        patid = varargin{3};
        trialname = varargin{4};    
        filename1 = visit1;
        filename2 = visit2;
     end
        
     
         %~~~Get first image~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if ~test %if runtest has not been called, prompt user for files
        % If an images directory exists, look there first
        path = set_path('./Images/','*.tif');
        % Open dialog box to select file
        [filename1,path1] = uigetfile(path, 'Select Past Image to Compare to More Recent');
         if isequal(filename1,0) || isequal(path1,0)
           disp('User pressed cancel')
           return
        else
           disp(['User selected ', fullfile(path1, filename1)])
        end
        fullpath = fullfile(path1,filename1);
    else % use visit arguments
        fullpath = fullfile('./Reg Set/',patid, visit1);
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
     img_sz = size(img1);
        
    
    
     %~~~Get second image~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
    if ~test %if runtest has not been called, prompt user for files
        % If an images directory exists, look there first
        path = set_path('./Images/','*.tif');
        % Open dialog box to select file
        [filename2,path2] = uigetfile(path, 'Select Image');
        if isequal(filename2,0) || isequal(path2,0)
           disp('User pressed cancel')
           return
        else
           disp(['User selected ', fullfile(path2, filename2)])
        end
        fullpath = fullfile(path2,filename2);
    else %use visit arguments  

        fullpath = fullfile('./Reg Set/',patid, visit2);
        
        
        output_dir = strcat('./Output Images/', patid);
             if exist(output_dir, 'dir') == false
                mkdir(output_dir); 
             end
      
         data.Trial = strcat(patid, trialname);
         data_filename = strcat(output_dir, '/', data.Trial);
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
     
         

    
    


  %~~~~~~~~% Ask for input points~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  if test % get optic disk and fovea from xml
      xDoc= xmlread('reg_images.xml');
	  images = xDoc.getElementsByTagName('image');
       for count = 1:images.getLength  
            image = images.item(count - 1);
            path = char(image.getAttribute('path'));
            if all(strcmpi(path, visit1))
                p.optic(1) = str2double(char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('x').item(0).getTextContent));
                p.optic(2) = str2double(char(image.getElementsByTagName('optic_disk').item(0).getElementsByTagName('y').item(0).getTextContent));
                p.fovea(1) = str2double(char(image.getElementsByTagName('macula').item(0).getElementsByTagName('x').item(0).getTextContent));
                p.fovea(2) = str2double(char(image.getElementsByTagName('macula').item(0).getElementsByTagName('y').item(0).getTextContent));
            end
       end

  else % get input points for fovea and optic disk from user
        h = figure('Name', 'Past Image');
        imshow(img1)
        title(strcat(filename1)) 
        disp('Select fovea')
        p.fovea = round(ginput(1));
        disp('Select optic disk')
        p.optic = round(ginput(1));  
        close(h)
  end
 
   
    %~~~~~~~~~~~Image Processing~~~~~~~~~~~~~~~~~~~ 
    
    % Run gaussian filter
     r = round(5/768*img_sz(1)); %scale filter size---5 by 5 pixs for 768 by 768 res (standard res - footer)
     c = round(5/768*img_sz(2));
     
     H = fspecial('gaussian', [r c], 5);
     proc2=imfilter(img2,H);
     proc1=imfilter(img1,H);
     
     
     if strcmpi(type,'AF')
      % Adjust contrasts/center pix distribution on mean intensity of ring between
         % macula and optic disk

         % create ring mask
         [xgrd, ygrd] = meshgrid(1:img_sz(2), 1:img_sz(1));   
          x = xgrd - p.fovea(1);    % offset the origin
          y = ygrd - p.fovea(2);
         ro= sqrt((p.optic(1)-p.fovea(1))^2+(p.optic(2)-p.fovea(2))^2)*.8;
         ri = sqrt((p.optic(1)-p.fovea(1))^2+(p.optic(2)-p.fovea(2))^2)*.5;
         ob = x.^2 + y.^2 <= ro.^2; %outer bound   
         ib = x.^2 + y.^2 >= ri.^2; %inner bound
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

           rep2 = mean(proc2(ring));
          if rep2 < 64
              gamma2 = 0.5;
          elseif rep2 >= 64 && rep2 < 96
              gamma2 = 0.75;
          elseif rep2 >=96 && rep2 < 160
              gamma2 = 1.0;
          elseif rep2 >= 160 && rep2 < 192
              gamma2 = 1.25;
          elseif rep2 >=192
              gamma2 = 1.5;
          end

          proc2 = imadjust(proc2,[],[],gamma2);

              
     elseif strcmpi(type,'FA')
         se1 = strel('line',img_sz(2)/2,0);
         se2 = strel('line',img_sz(1)/2,90);
         gamma = 0.75;
         
         proc1=imtophat(proc1,se1);
         proc1=imtophat(proc1,se2);
         proc1=imadjust(proc1,[],[],gamma);
         
         proc2=imtophat(proc2,se1);
         proc2=imtophat(proc2,se2);
         proc2=imadjust(proc2, [],[],gamma);         
     end
     
     %Create macular windows
       lbound = p.fovea(1) - round(abs(p.fovea(1) - p.optic(1))*.5);
       rbound = p.fovea(1) + round(abs(p.fovea(1) - p.optic(1))*.5);
       if lbound < 1
           lbound = 1;
       end
       if rbound > img_sz(2)
           rbound = img_sz(2);
       end
       width = lbound : rbound;
      
       bbound = p.fovea(2) + round(abs(p.fovea(1) - p.optic(1))*.5);
       tbound = p.fovea(2) - round(abs(p.fovea(1) - p.optic(1))*.5);
       if tbound < 1 
           tbound = 1;
       end
       if bbound > img_sz(1)
           bbound = img_sz(1);
       end
       height =  tbound : bbound;

   win1 = proc1(height,width);
   winsz = size(win1);
   win2 = proc2(height,width);
   
   if strcmpi(type,'AF')

   % standardize intensities
       [BWhypo1, Ihypo1]  = machypo_detect(win1);
       [BWhyper1, Ihyper1] = machyper_detect(win1, BWhypo1);    
       [BWhypo2, Ihypo2]  = machypo_detect(win2);
       [BWhyper2, Ihyper2] = machyper_detect(win2, BWhypo2);

       %match histograms of image 2 to image 1


        win2 = histeq(win2, imhist(win1));

       hypo = imhist(win1(BWhypo1));
       hyper = imhist(win1(BWhyper1));
       background  = imhist(win1(~BWhyper1 & ~BWhypo1));

       [~, Thypo] = histeq(win2(BWhypo2),hypo);
       [~,Thyper] = histeq(win2(BWhyper2),hyper);
       [~,Tback] = histeq(win2(~BWhyper2 & ~BWhypo2),background);

       for i = 1:size(win2,2)
           for j = 1:size(win2,1)
               level = win2(i,j);
               if BWhypo2(i,j) 
                   win2(i,j) = Thypo(level+1)*255;
               elseif BWhyper2(i,j) 
                   win2(i,j) = Thyper(level+1)*255;
               elseif BWhyper2(i,j) 
                   win2(i,j) = Tback(level+1)*255;
               end
           end
       end
   end
   
   %Get percent change hyper/hypo
   
   data.HYPR = numel(win2(BWhyper2))/numel(win2) - numel(win1(BWhyper1))/numel(win1);
   data.HYPO = numel(win2(BWhypo2))/numel(win2) - numel(win1(BWhypo1))/numel(win1);
   
      % Create a figure for the maculas before and after segmentation
    if test
        h = figure('Name','Segmentation Results','visible','off');
    else
        figure('Name','Segmentation Results');
    end
        subplot(2,3,1);
        imshow(img1(height,width)); title('Original Image 1');
        subplot(2,3,2);
        imshow(Ihypo1); title('Hypo Segmented Image 1');
        subplot(2,3,3);
        imshow(Ihyper1); title('Hyper Segmented Image 1');
        subplot(2,3,4);
        imshow(img2(height,width)); title('Original Image 2');
        subplot(2,3,5);
        imshow(Ihypo2); title('Hypo Segmented Image 2');
        subplot(2,3,6);
        imshow(Ihyper2); title('Hyper Segmented Image 2');
    if test
        saveas(h, strcat(data_filename, '-segmentation '),'png');
        close(h)
    end
   
      
    % Create a figure for the maculas before and after intensity
    % standardization
    if test
        h = figure('Name','Processing Results','visible','off');
    else
        figure('Name','Processing Results');
    end
        subplot(2,2,1);
        imshow(img1(height,width)); title(strcat('Original ', filename1));
        subplot(2,2,2);
        imshow(win1); title(strcat('Processed ', filename1));
        subplot(2,2,3);
        imshow(img2(height,width)); title(strcat('Original', filename2));
        subplot(2,2,4);
        imshow(win2); title(strcat('Processed ', filename2));
    if test
        saveas(h, strcat(data_filename, '-processing'),'png');
        close(h)
    end
    
       
%     %~~~~~~~~Determine Thresholds for MAQ calculation~~~~~~~~~~~
%     
%     % Get standard deviation of background pixel intensity for img1
    win1back = double(win1(~BWhyper1 & ~BWhypo1));
    hypr_thresh = std(win1back(:));
    hypo_thresh = -1*std(win1back(:));

  
   
 %~~~~~~~~~~~~~~Analyze Maculas~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   

   
    %~~~~Show Disease Progress~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if test
    	 h = figure('Name', 'Macular Comparison','visible','off');
    else
         h = figure('Name', 'Macular Comparison');
    end
    subplot(2,2,1);
    imshow(win1); title('Previous Visit');
    subplot(2,2,2);
    imshow(win2); title('Current Visit');
    subplot(2,2,3);
    imshow(win2); title('Progression');
    h5=gca;
   

    

    %Calculate MAQ
    win_avg1 = zeros(50,50);
    win_avg2 = zeros(50,50);
    xln = winsz(2)/50; %create 50 by 50 grid
    yln = winsz(1)/50;
    m=1;
    for i = 1:yln:winsz(1)-yln+1
        k=1; 
         for j = 1:xln:winsz(2)-xln+1
            bloc = win1(round(i):round(i+yln)-1, round(j):round(j+xln)-1);
            win_avg1(m,k)  = round(mean2(bloc));
            k=k+1;
        end
        m=m+1;
    end
       m=1;
    for i = 1:yln:winsz(1)-yln+1
        k=1; 
         for j = 1:xln:winsz(2)-xln+1
            bloc = win2(round(i):round(i+yln)-1, round(j):round(j+xln)-1);
            win_avg2(m,k)  = round(mean2(bloc));
            k=k+1;
        end
        m=m+1;
    end
    
    %divide sum of squared differences (deviations from expected value of zero) by grid size to get variance

    DBW = win_avg2 - win_avg1;
    if strcmpi(type,'AF') 
        data.MAQ = (sum(DBW(DBW<hypo_thresh).^2)+sum(DBW(DBW>hypr_thresh).^2)/(50*50)); 
    elseif strcmpi(type,'FA')
     data.MAQ = (sum(DBW(DBW>hypr_thresh).^2)/(50*50)); 
    end
         
     %Show gridlines for MAQ calculation
    hold(h5);
    for k = 0.5:yln:winsz(1)-rem(winsz(1),yln)+0.5
    x = [0.5 winsz(2)+0.5];
    y = [k k];
    plot(h5,x,y,'Color','k','LineStyle','-');
    end

    for k = 0.5:xln:winsz(2)-rem(winsz(2),xln)+0.5
    x = [k k];
    y = [0.5 winsz(1)+0.5];
    plot(h5,x,y,'Color','k','LineStyle','-');
    end
    hold off
    
   % ~~~~~~~Show changes in hypo/hyper regions~~~~~~~~~~~~~~~~~~~~~~~~~
    
    redx=ones(4,250);
    yellx=ones(4,250);
    redy=ones(4,250);
    yelly=ones(4,250);

    
    m = 1; 
    p1 = 1;
    p2 = 1;
    for i = 0.5:yln:winsz(1)-rem(winsz(1),yln)-yln+0.5
        k=1;
        for j = 0.5:xln:winsz(2)-rem(winsz(2),xln)-xln+0.5
         if DBW(m,k) > hypr_thresh
            yelly(:,p1) = [i;i;i+yln;i+yln]; %specify vertices of patches
            yellx(:,p1) = [j;j+xln;j+xln;j];
            p1=p1+1;
         elseif DBW(m,k) < hypo_thresh
            redy(:,p2) = [i;i;i+yln;i+yln];
            redx(:,p2) = [j;j+xln;j+xln;j];
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
        if strcmpi(type,'AF')
            alpha(patch(redx,redy,'r'),.5); 
        end
        alpha(patch(yellx,yelly,'y'),.5);
        hold off
  
         set(h5, 'Position', [0.27 0.02000 1.5*0.3347 1.5*0.3338]); % Increase size of progression image
        
    if test
        saveas(h, strcat(data_filename, '-progression'),'png');
        close(h)
    else
        fprintf('Results: \n');
        disp(data);
    end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
    
    
    
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
