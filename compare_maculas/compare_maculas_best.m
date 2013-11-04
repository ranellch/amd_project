function [ data ] = compare_maculas_best(type, varargin)
% Process Image
    %type = 'FA' or 'AF'

    % Create a struct for the curve data
    data = struct(...
                  'Trial', '', ...    
                  'HPRS', [], ...
                  'HPOS', [], ...
                  'MAQ',  [] ...
                 );

 
     p = struct('fovea', [0 0], 'optic', [0 0]);
     if ~isempty(varargin) && length(varargin) ~=5
         disp('Invalid arguments entered');
         return
     end
     
     test = ~isempty(varargin);
     if test
        visit1 = varargin{1};
        visit2 = varargin{2};
        patid = varargin{3};
        trialname = varargin{4};
        directory = varargin{5};
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
        fullpath = fullfile(directory,patid, visit1);
    end
     

    
      % Read the image
    imgRGB=imread(fullpath);
    RGB_test=size(size(imgRGB));
    if(RGB_test(2)==3)
        img1=rgb2gray(imgRGB);
    else
        img1=imgRGB;
    end
    

        
    
    
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

        fullpath = fullfile(directory,patid, visit2);
        
        
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
 

    img_sz = size(img1);
   
    %~~~~~~~~~~~Image Processing~~~~~~~~~~~~~~~~~~~ 
    %Gaussian blur
    H = fspecial('gaussian',[5 5],1.0);
    proc1 = imfilter(img1,H);
    proc2 = imfilter(img2,H);
     
     
     if strcmpi(type,'AF')
         
        %Run smooth_illum to remove illumination and contrast drifts
        %Get segmented backgrounds for linear histogram matching
        
        [proc1,background1] = smooth_illum_getbackground(proc1);
        [proc2,background2] = smooth_illum_getbackground(proc2);
        
        %Create a figure for the segmented backgrounds
      if test
        h = figure('Name','Processing Results','visible','off');
      else
        figure('Name','Processing Results');
      end
        subplot(1,2,1);
        imshow(background1); title(strcat('Background of Img1: ', filename1));
        subplot(1,2,2);
        imshow(background2); title(strcat('Background Img2: ', filename2));
      if test
        saveas(h, strcat(data_filename, '-backgrounds'),'png');
        close(h)
      end

        
        %Shift mean of img2 histogram to mean of img1 histogram based on background pixels
        
        
%         Y = [proc2(background2&background1),ones(length(proc2(background2&background1)),1)];
%         X = proc1(background1&background2);
%         numpoints = min([size(Y,1), length(X)]);      
%         Y = Y(1:numpoints,:);
%         X = X(1:numpoints);
%         b = Y\X;
%         proc2 = proc2.*b(1)+b(2); 
%         proc2 = mat2gray(proc2, [0 1]);
%         
%         proc1(proc1~=0) = im2uint8(proc1(proc1~=0));
%         proc2(proc2~=0) = im2uint8(proc2(proc2~=0));

        
        corr_factor = mean(proc2(background2&background1)) - mean(proc1(background1&background2));

        proc1 = im2uint8(proc1);
        proc2 = im2uint8(proc2-corr_factor);
        

     elseif strcmpi(type,'FA')
            error('functionality not available');
            
     end
           
      
     
    % Create a figure for the images before and after processing
    if test
        h = figure('Name','Processing Results','visible','off');
        subplot(2,2,1);
        imshow(img1); title(strcat('Original', filename1));
        subplot(2,2,2);
        imshow(proc1); title(strcat('Processed ', filename1));
        subplot(2,2,3);
        imshow(img2); title(strcat('Original', filename2));
        subplot(2,2,4);
        imshow(proc2); title(strcat('Processed ', filename2));
        saveas(h, strcat(data_filename, '-processing'),'png');
        close(h)
    else
        figure('Name','Processing Results');
        subplot(2,2,1);
        imshow(img1); title(strcat('Original', filename1));
        subplot(2,2,2);
        imshow(proc1); title(strcat('Processed', filename1));
        subplot(2,2,3);
        imshow(img2); title(strcat('Original', filename2));
        subplot(2,2,4);
        imshow(proc2); title(strcat('Processed', filename2));
    end
    
       
    %~~~~~~~~Determine Thresholds for MAQ calculation~~~~~~~~~~~
    
    % Get standard deviation of pixel inensity in background
    periph = double(proc1(background1));
    hypr_thrsh = 2*std(periph(:));
    hypo_thrsh = -2*std(periph(:));

  
   
 %~~~~~~~~~~~~~~Analyze Maculas~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
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
  

%        
%        win2= contrast_stretch(win2, mean2(win2), 2);
%        win1 = contrast_stretch(win1,mean2(win1),2);
       


    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~       
    % Show maculas if not using runtest
    if ~test
        figure('Name', 'Areas of Interest');
        subplot(1,2,1);
        colormap(gray), imagesc(win1); 
        subplot(1,2,2);
        colormap(gray), imagesc(win2);
    end
    
   
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
    
%     prog=win1-win2;
%     hypo_thrsh = -40;
%     hypr_thrsh = 40;
% 
%         
%     redx=ones(1,1000);
%     yellx=ones(1,1000);
%     redy=ones(1,1000);
%     yelly=ones(1, 1000);
% 
%     
%     m=1;
%     k=1;
%     for i=1:winsz(1)
%         for j = 1:winsz(2)
%             if prog(i,j) > hypr_thrsh
%                 yellx(m) = j;
%                 yelly(m) = i;
%                 m=m+1;
%             elseif prog(i,j) < hypo_thrsh
%                 redx(k) = j;
%                 redy(k) = i;
%                 k=k+1;
%             end
%         end
%     end
%     hold(h5)
%     plot(h5, yellx, yelly, '.y', redx, redy, '.r');

    

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
            win_avg1(m,k)  = mean2(bloc);
            k=k+1;
        end
        m=m+1;
    end
       m=1;
    for i = 1:yln:winsz(1)-yln+1
        k=1; 
         for j = 1:xln:winsz(2)-xln+1
            bloc = win2(round(i):round(i+yln)-1, round(j):round(j+xln)-1);
            win_avg2(m,k)  = mean2(bloc);
            k=k+1;
        end
        m=m+1;
    end
    
    %divide sum of squared differences (deviations from expected value of zero) by grid size to get variance

    DWB = win_avg2 - win_avg1;
    if strcmpi(type,'AF')
        data.HPOS = sum(DWB(DWB<hypo_thrsh).^2);
        data.HPRS = sum(DWB(DWB>hypr_thrsh).^2);
        data.MAQ = (data.HPOS+data.HPRS)/(50*50); 
    elseif strcmpi(type,'FA')
        data.HPRS = sum(DWB(DWB>hypr_thrsh).^2);
        data.MAQ = (data.HPRS)/(50*50); 
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
         if DWB(m,k) > hypr_thrsh
            yelly(:,p1) = [i;i;i+yln;i+yln]; %specify vertices of patches
            yellx(:,p1) = [j;j+xln;j+xln;j];
            p1=p1+1;
         elseif DWB(m,k) < hypo_thrsh
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
