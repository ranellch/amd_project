function [ data ] = compare_maculas()
% Process Image

    % Create a struct for the curve data
    data = struct('surf_new',[], ...
                  'surf_old',[], ...
                  'yx_ratio', [],...
                  'eye'  , '', ...
                  'DWB' , [], ...
                  'HPRS', [], ...
                  'HPOS', [], ...
                  'MAQ',  [] ...
                 );

    % If an images directory exists, look there first
    path = set_path('./Images/','*.tif');

    % Open dialog box to select file
    [image_filename1,image_pathname1] = uigetfile(path, 'Select Image to Process');
    fullpath = fullfile(image_pathname1,image_filename1);
    
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
         
    % Ask for input points
    figure('Name', image_filename1);
    imshow(img1);
    %uiwait(msgbox('Please click on fovea', '','modal')); 
    p = struct('fovea', [], 'optic_disk', []);
    p.fovea = round(ginput(1));
    %uiwait(msgbox('Please click on optic disk','', 'modal'));
    p.optic_disk = round(ginput(1));
    disp('Points Selected:');
    disp(p);
    
   %~~~~~~~~~~~Image Processing~~~~~~~~~~~~~~~~~~~ 
    
    % Run gaussian filter
     r1 = round(10/770*img_sz1(1)); %scale filter size---10 by 10 pixs for 768 by 770 res (standard res - footer)
     c1 = round(10/768*img_sz1(2));
     
     H = fspecial('gaussian', [r1 c1], 5);
    proc1=imfilter(img1,H);
     
    % Create circle mask
    x2=p.fovea(2); 
    y2=p.fovea(1);
    [xgrid, ygrid] = meshgrid(1:img_sz1(2), 1:img_sz1(1));   
    x = xgrid - x2;    % offset the origin
    y = ygrid - y2;
    r=sqrt((p.optic_disk(2)-p.fovea(2))^2+(p.optic_disk(1)-p.fovea(1))^2)/2;
    circlemask = x.^2 + y.^2 <= r.^2;
    
    
    
%     % Smooth intensity gradients 
%     se = strel('square',31);
%     proc1(~circlemask) = imtophat(proc1(~circlemask),se);
    
    % Adjust contrast

     proc1 = contrast_stretch(proc1, 3);

  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Create a figure for the image before and after processing
    figure('Name',image_filename1);
    subplot(1,2,1);
    imshow(img1); title('Original');
    subplot(1,2,2);
    imshow(proc1); title('Processed');
 
    % Determine if left or right eye
    if p.fovea(1) > p.optic_disk(1)
        data.eye = 'l';
    elseif p.fovea(1) < p.optic_disk(1)
        data.eye = 'r';
    end
    
 

   %Create macular window
       lbound = p.fovea(1) - round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       rbound = p.fovea(1) + round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       if lbound < 1
           lbound = 1;
       end
       if rbound > img_sz1(2)
           rbound = img_sz1(2);
       end
       width = lbound : rbound;
      
       bbound = p.fovea(2) + round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       tbound = p.fovea(2) - round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       if tbound < 1 
           tbound = 1;
       end
       if bbound > img_sz1(1)
           bbound = img_sz1(1);
       end
       height =  tbound : bbound;

   win1 = proc1(height,width);
   sz1 = size(win1);
   data.yx_ratio = abs(p.fovea(1) - p.optic_disk(1))/(p.fovea(2) - p.optic_disk(2));
    
    %~~~Get second image~~~~~
    
    % If an images directory exists, look there first
    path = set_path('./Images/','*.tif');

    % Open dialog box to select file
    [image_filename2,image_pathname2] = uigetfile(path, 'Select Image to Compare');
    img_path = fullfile(image_pathname2,image_filename2);
    
    % Read the image
    imgRGB=imread(img_path);
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
        
    
   % Ask for input points
    figure('Name', image_filename2);
    imshow(img2);
    %uiwait(msgbox('Please click on fovea', '','modal')); 
    p = struct('fovea', [], 'optic_disk', []);
    p.fovea = round(ginput(1));
    %uiwait(msgbox('Please click on optic disk','', 'modal'));
    p.optic_disk = round(ginput(1));
    disp('Points Selected:');
    disp(p);
    
    %~~~~~~~~~~~Image Processing~~~~~~~~~~~~~~~~~~~ 
    
    % Run gaussian filter
     r2 = round(10/770*img_sz2(1)); %scale filter size---10 by 10 pixs for 768 by 770 res (standard res - footer)
     c2 = round(10/768*img_sz2(2));
     
     H = fspecial('gaussian', [r2 c2], 5);
    proc2=imfilter(img2,H);
     
    % Create circle mask
    x2=p.fovea(2); 
    y2=p.fovea(1);
    [xgrid, ygrid] = meshgrid(1:img_sz1(2), 1:img_sz1(1));   
    x = xgrid - x2;    % offset the origin
    y = ygrid - y2;
    r=sqrt((p.optic_disk(2)-p.fovea(2))^2+(p.optic_disk(1)-p.fovea(1))^2)/2;
    circlemask = x.^2 + y.^2 <= r.^2;
    
    
    
%     % Remove background gradients 
%     se = strel('square',31);
%     proc2(~circlemask) = imtophat(proc2(~circlemask),se);
%    
    % Adjust contrast

     proc2 = contrast_stretch(proc2, 3);

  %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    % Create a figure for the image before and after processing
    figure('Name',image_filename1);
    subplot(1,2,1);
    imshow(img2); title('Original');
    subplot(1,2,2);
    imshow(proc2); title('Processed');

    %Create macular window
       lbound = p.fovea(1) - round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       rbound = p.fovea(1) + round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       if lbound < 1
           lbound = 1;
       end
       if rbound > img_sz2(2)
           rbound = img_sz2(2);
       end
       width = lbound : rbound;
      
       bbound = p.fovea(2) + round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       tbound = p.fovea(2) - round(abs(p.fovea(1) - p.optic_disk(1))*.5);
       if tbound < 1 
           tbound = 1;
       end
       if bbound > img_sz2(1)
           bbound = img_sz2(1);
       end
       height =  tbound : bbound;

       win2 = proc2(height,width);
       sz2 = size(win2);
       
    %Call Nate's function
       
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
    title(strcat('Previous Visit: ',image_filename2)); 
    view(153, 78);
    subplot(1,2,2);
    surf(fliplr(double(win1)),'EdgeColor', 'none');   
    title(strcat('Current Visit:',image_filename1));
    view(153, 78);
    
   
    %~~~~Show disease progress~~~~~
    
    
    figure('Name', 'Macular Comparison');
    subplot(1,3,1);
    imshow(win2); title('Previous Visit');
    h4=gca;
    subplot(1,3,2);
   imshow(win1); title('Current Visit');
    subplot(1,3,3);
    imshow(win1); title('Progression');
    h5=gca;

    
    %Calculate MAQ
    win_avg1 = zeros(1000,1000);
    win_avg2 = zeros(1000,1000);
    xln1 = round(10/500*sz1(2)); %scale grid boxes---10 by 10 pixs for 500 by 600 window
    yln1 = round(10/600*sz1(1));
    xln2 = round(10/500*sz2(2));
    yln2 = round(10/600*sz2(1));
    m=1;
    for i = 1:yln1:sz1(1)-rem(sz1(1),yln1)-yln1+1
        k=1; 
         for j = 1:xln1:sz1(2)-rem(sz1(2),xln1)-xln1+1
            bloc = win1(i:i+yln1-1, j:j+xln1-1);
            win_avg1(m,k)  = mean2(bloc);
            k=k+1;
        end
        m=m+1;
    end
       m=1;
    for i = 1:yln2:sz2(1)-rem(sz2(1),yln2)-yln2+1
        k=1; 
         for j = 1:xln2:sz2(2)-rem(sz2(2),xln2)-xln2+1
            bloc = win2(i:i+yln2-1, j:j+xln2-1);
            win_avg2(m,k)  = mean2(bloc);
            k=k+1;
        end
        m=m+1;
    end
    
    data.DWB = win_avg1 - win_avg2;
    data.HPOS = sum(sum(data.DWB(data.DWB<0)));
    data.HPRS = sum(sum(data.DWB(data.DWB>0)));
    data.MAQ = sum(sum(data.DWB));
    
     %Show gridlines for DAN calculation
    hold(h5);
    for k = 1:yln1:sz1(1)-rem(sz1(1),yln1)+1
    x = [1 sz1(2)];
    y = [k-1 k-1];
    plot(h5,x,y,'Color','k','LineStyle','-');
    end

    for k = 1:xln1:sz1(2)-rem(sz1(2),xln1)+1
    x = [k-1 k-1];
    y = [1 sz1(1)];
    plot(h5,x,y,'Color','k','LineStyle','-');
    end
    hold off
    
    % Show changes in hypo/hyper regions
    
    redx=ones(4,1000);
    yellx=ones(4,1000);
    redy=ones(4,1000);
    yelly=ones(4,1000);
    
    m = 1; 
    p1 = 1;
    p2 = 1;
    for i = 1:yln1:sz1(1)-rem(sz1(1),yln1)-yln1+1
        k=1;
        for j = 1:xln1:sz1(2)-rem(sz1(2),xln1)-xln1+1
         hypr_thrsh = 50;
         hypo_thrsh = -50;
         if data.DWB(m,k) > hypr_thrsh
            yelly(:,p1) = [i-1;i-1;i-1+yln1;i-1+yln1]; %specify vertices of patches
            yellx(:,p1) = [j-1;j-1+xln1;j-1+xln1;j-1];
            p1=p1+1;
         elseif data.DWB(m,k) < hypo_thrsh
            redy(:,p2) = [i-1;i-1;i-1+yln1;i-1+yln1];
            redx(:,p2) = [j-1;j-1+xln1;j-1+xln1;j-1];
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

    
    fprintf('Results: \n');
    disp(data);
    
    
%     % If a data directory exists, start there to save
%     path = set_path('Data','');
% 
%     % Open dialog box to save the data in the Data directory
%     data_filename = fullfile(path, strrep(image_filename1,'.tif','.mat'));
%     
%     % Store the surfaces into our structure
%     data.surf_new = surf_new;
%     data.surf_old = surf_old;
%     
%     % Save the structure under the filename data_filename
%     save(data_filename,'data');
%     fprintf('Processed Image Data Saved As: \n%s\n', data_filename);


end
