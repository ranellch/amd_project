function GaborWaveletRepresentation
% clear;
close all

[im2, res, param] = analyzeAndReconstruction;
close all

max_im2 = max(im2(:));
min_im2 = min(im2(:));
imageSize = size(im2, 1); % image is assumed to be square

%% 
h_figure = figure(1); clf;


set(h_figure, 'Units', 'normalized')

subplot(2,3,1)
clim = max(abs([min_im2 max_im2])) * [-1 1];
% clim = [min_im2 max_im2];
imagesc(im2',clim);
axis xy square; colormap gray

set(gca, 'tickDir', 'out')
title('Original Image', 'FontSize', 14)

h_subplot2 = subplot(2,3,2);
imagesc([0,0;0,0]',[0,1])
axis xy square
title('select positions', 'FontSize', 14)

h_subplot3 = subplot(2,3,3);
title('Scale & Orientation', 'FontSize', 14)

h_subplot4 = subplot(2,3,4);
axis square

h_subplot5 = subplot(2,3,5);
title('Wavelet Added', 'FontSize', 14)
axis square

h_subplot6 = subplot(2,3,6);
title('Selected Gabor Wavelet', 'FontSize', 14)
axis square

h_resetButton        = uicontrol('Style',  'pushbutton',...
                          'String', 'reset',...
                          'FontSize', 14,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.88, 0.03, 0.1, 0.05],...
                          'callback', @myCallback_resetButton);

h_selectAllButton    = uicontrol('Style',  'pushbutton',...
                          'String', 'select all',...
                          'FontSize', 10,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.46, 0.52, 0.1, 0.03],...
                          'callback', @myCallback_selectAll);

UserData.flag.interrupt = 0;
h_addNwaveletsButton = uicontrol('Style',  'pushbutton',...
                          'String', 'add N wavelets',...
                          'FontSize', 14,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.41, 0.03, 0.22, 0.05],...
                          'callback', @myCallback_addNwavelets,...
                          'UserData', UserData);
                      
h_loadButton         = uicontrol('Style',  'pushbutton',...
                          'String', 'load',...
                          'FontSize', 14,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.07, 0.03, 0.1 0.05],...
                          'callback', @myCallback_loadButton);
                      

h_showComponentButton= uicontrol('Style',  'pushbutton',...
                          'String', 'show pyramid',...
                          'FontSize', 10,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.74, 0.53 0.13 0.03],...
                          'callback', @myCallback_showPyramidButton);
                      
h_normalizeCheckbox= uicontrol('Style',  'Checkbox',...
                          'String', 'normalize each scale',...
                          'FontSize', 10,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.71, 0.495 0.25 0.03],...
                          'Value', 1);

numAdded = 0;
bgColor = get(gcf, 'Color');
h_textNumAdded = uicontrol('Style',  'text',...
                          'String', num2str(numAdded),...
                          'FontSize', 14,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.2, 0.02, 0.18, 0.05],...
                          'HorizontalAlignment', 'right',...
                          'Backgroundcolor', bgColor);

h_textN        = uicontrol('Style',  'text',...
                          'String', 'N =',...
                          'FontSize', 14,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.64, 0.02, 0.05, 0.05],...
                          'Backgroundcolor', bgColor);
                      
addNumber = 1000;
h_editaddNumber = uicontrol('Style',  'edit',...
                          'String', addNumber,...
                          'FontSize', 14,...
                          'Parent', h_figure,...
                          'Units', 'normalized',...
                          'Position', [	0.70, 0.02, 0.1, 0.07]);
                      
pauseTime = 0;
h_slider       = uicontrol('Style', 'slider',...
                          'Min', 0, 'Max',0.3, 'Value', pauseTime,...
                          'Units', 'normalized',...
                          'Position', [0.13 0.48 0.2 0.05]);
                      
uicontrol('Style',  'text',...
          'String', 'fast',...
          'FontSize', 10,...
          'Parent', h_figure,...
          'Units', 'normalized',...
          'Position', [	0.09, 0.47, 0.04, 0.05],...
          'Backgroundcolor', bgColor);
                      
uicontrol('Style',  'text',...
          'String', 'slow',...
          'FontSize', 10,...
          'Parent', h_figure,...
          'Units', 'normalized',...
          'Position', [	0.33, 0.47, 0.04, 0.05],...
          'Backgroundcolor', bgColor);

h.figure    = h_figure;
h.subplot2  = h_subplot2;
h.subplot3  = h_subplot3;
h.subplot4  = h_subplot4;
h.subplot5  = h_subplot5;
h.subplot6  = h_subplot6;
h.param     = param;
h.imageSize = imageSize;
h.res       = res;

h.resetButton        = h_resetButton;
h.selectAllButton    = h_selectAllButton;
h.addNwaveletsButton = h_addNwaveletsButton;
h.loadButton         = h_loadButton;
h.showComponentButton= h_showComponentButton;
h.slider             = h_slider;
h.normalizeCheckbox  = h_normalizeCheckbox;

h.textNumAdded       = h_textNumAdded;
h.textN              = h_textN;
h.editaddNumber      = h_editaddNumber;

h.pauseTime = pauseTime;

h.flag.setGabor     = 0;
h.flag.addNwavelets = 0;
h.flag.showPyramid  = 0;
h.flag.selectAll    = 0;
h.flag.ampNormalize = 0;

h.numAdded = numAdded;

guidata(h_figure, h);

initializeTmpRes;
initializeTmpImage
initializeSubplots;
setGaborWavelet(h.figure);
setSizeGaborWavelet;
sortWavelets;

set(h_figure, 'WindowButtonMotionFcn', @myCallback_ButtonMotion,...
              'WindowButtonDownFcn'  , @myCallback_ButtonDown,...
              'WindowButtonUpFcn'    , @myCallback_ButtonUp)

function initializeSubplots

    h = guidata(gcf);

    subplot(h.subplot3)

    param    = h.param;
    numScale = param.m;
    % numOR    = param.K * 2;
    numOR    = param.K;

    % theta = (0: 2*pi/numOR: 2*pi - 2*pi/numOR) - 2*pi/numOR/2; 
    theta = (0: pi/numOR: 2*pi - pi/numOR) - pi/numOR/2; 
    rho   = zeros([1, numOR*2]);
    p = polar([theta; theta],[rho; rho+1], 'k:');
    
    hold on
    h_line = findall(gca,'type','line');
    for ii = 1: size(p)
        h_line(h_line == p(ii)) = [];
    end
    delete(h_line)
    
    h_text = findall(gca,'type','text');
    ticks  = 0:30:330;
    for ii = 1: length(ticks)
        for jj = 1: length(h_text)
            if jj > length(h_text), break, end
            if strcmp(get(h_text(jj), 'String'), num2str(ticks(ii))) ||...
                    strcmp(get(h_text(jj), 'String'), '')
                h_text(jj) = [];
                continue
            end
        end
    end
    
    delete(h_text)
    
    theta_grid = linspace(0, 2*pi, 101);
    rho_grid   = ones(1,101);
    polar(theta_grid, rho_grid, 'k')
    for ii = 1: numScale
        polar(theta_grid, rho_grid/numScale * ii, 'k:')
    end
    
    ind_rho   = floor(numScale/2);
    ind_theta = 0;
    
    h_fill      = zeros([1,2]);
    h_fillBlack = zeros([1,2]);
    
    for ii = 1:2
        tmp_theta = ind_theta + numOR/2 * (ii-1);
        X = [ind_rho   /numScale*cos([2*pi * tmp_theta/numOR - pi/numOR/2,...
                                      2*pi * tmp_theta/numOR,...
                                      2*pi * tmp_theta/numOR + pi/numOR/2]),...
            (ind_rho+1)/numScale*cos([2*pi * tmp_theta/numOR + pi/numOR/2,...
                                      2*pi * tmp_theta/numOR,...
                                      2*pi * tmp_theta/numOR - pi/numOR/2])];
        Y = [ind_rho   /numScale*sin([2*pi * tmp_theta/numOR - pi/numOR/2,...
                                      2*pi * tmp_theta/numOR,...
                                      2*pi * tmp_theta/numOR + pi/numOR/2]),...
            (ind_rho+1)/numScale*sin([2*pi * tmp_theta/numOR + pi/numOR/2,...
                                      2*pi * tmp_theta/numOR,...
                                      2*pi * tmp_theta/numOR - pi/numOR/2])];
        h_fill(ii)      = fill(X,Y,[.75,.75,.75]);

        h_fillBlack(ii) = fill(X,Y,[  0,  0,  0]);
    end
    hold off
    title('Scale & Orientation', 'FontSize', 14)

    h.fill      = h_fill;
    h.fillBlack = h_fillBlack;

    ind_scale = numScale - ind_rho;
    if ind_theta < numOR/2
        ind_OR = ind_theta + 1;
        phase = 0;
    else
        ind_OR = ind_theta - numOR/2 + 1;
        phase = 1;
    end

    h.ind_rho   = ind_rho;
    h.ind_theta = ind_theta;
    h.ind_scale = ind_scale;
    h.ind_OR    = ind_OR;
    h.phase     = phase;

    h.currentScale = ind_scale;
    h.currentOR    = ind_OR;
    h.currentPhase = phase;
    
    guidata(h.figure, h)
    setSubplot232
    
function myCallback_ButtonMotion(~,~)

    [~, hFigure] = gcbo;
    figure(hFigure)
    
    [pos] = get(hFigure, 'CurrentPoint');
    h = guidata(hFigure);
    
    if abs( pos(1) - 3/6) < 1/6 && pos(2) > 1/2       % mouse is on the subplot232

        % flag is off when the mouse cursor is on the subplot 232
        h.flag.setGabor = 0;
        setGaborWavelet(h.figure)
        
    elseif abs(pos(1) - 5/6) < 1/6 && pos(2) > 1/2 % && h.flag.setGabor == 0 
    % mouse is on the subplot233 and Gabor Wavelet is not set
        h.flag.setGabor = 1;
        
        tmpPos = get(h.subplot3, 'CurrentPoint');   % get the mouse position on the subplot233 axis
        x = tmpPos(1,1,1); y = tmpPos(1,2,1);
        rho   = sqrt(x^2 + y^2);  % radius
        theta = atan2(y,x);
        
        if rho <= 1 
            %%
            param    = h.param;
            numScale = param.m;
            % numOR    = param.K * 2;
            numOR    = param.K;
            
            subplot(h.subplot3)
            hold on
            % hold on
            % polar(theta, rho, 'k*')
            % hold off
            ind_rho   = floor(rho*numScale);
            % ind_theta = round(theta/2/pi * numOR);
            ind_theta = round(theta/pi * numOR);
            if ind_theta < 0
                % ind_theta = mod(ind_theta + numOR, numOR);
                ind_theta = ind_theta + numOR;
            end

            h_fill      = zeros([1,2]);
            
            for ii = 1:2
                % tmp_theta = ind_theta + 8 * (ii-1);
                tmp_theta = ind_theta + numOR * (ii-1);
                X = [ind_rho   /numScale*cos([pi * tmp_theta/numOR - pi/numOR/2,...
                                              pi * tmp_theta/numOR,...
                                              pi * tmp_theta/numOR + pi/numOR/2]),...
                    (ind_rho+1)/numScale*cos([pi * tmp_theta/numOR + pi/numOR/2,...
                                              pi * tmp_theta/numOR,...
                                              pi * tmp_theta/numOR - pi/numOR/2])];
                Y = [ind_rho   /numScale*sin([pi * tmp_theta/numOR - pi/numOR/2,...
                                              pi * tmp_theta/numOR,...
                                              pi * tmp_theta/numOR + pi/numOR/2]),...
                    (ind_rho+1)/numScale*sin([pi * tmp_theta/numOR + pi/numOR/2,...
                                              pi * tmp_theta/numOR,...
                                              pi * tmp_theta/numOR - pi/numOR/2])];
                
                delete(h.fill(ii));                          
                h_fill(ii) = fill(X,Y,[.75,.75,.75]);
            end
            h.fill = h_fill;
            
            hold off
            
            %%
            ind_scale = numScale - ind_rho;
            if ind_theta < numOR
                ind_OR = ind_theta + 1;
                phase = 0;
            else
                ind_OR = ind_theta - numOR + 1;
                phase = 1;
            end

            % GaborFilters(:,:,OR,Scale,phase)
            h.ind_rho   = ind_rho;
            h.ind_theta = ind_theta;
            h.ind_scale = ind_scale;
            h.ind_OR    = ind_OR;
            h.phase     = phase;

            guidata(h.figure, h)
            setGaborWavelet(h.figure)
        else
            h.flag.setGabor = 0;
            setGaborWavelet(h.figure)
        end
    end
    guidata(h.figure, h)

function myCallback_ButtonMotion2(~, ~)
    
    [~, hFigure] = gcbo;

    h = guidata(hFigure);

    tmpPos = get(h.subplot2, 'CurrentPoint');

    x = round(tmpPos(1,1,1)); y = round(tmpPos(1,2,1));

    currentScale = h.currentScale;
    currentOR    = h.currentOR;

    tmpRes       = h.tmpRes;
    tmp          = tmpRes{currentScale, currentOR};
    sizeRes      = h.sizeRes;

    numAdded     = h.numAdded;
    
    if x > 0 && y > 0 && x <= size(tmp,1) && y <= size(tmp,2)

        imageSize= h.imageSize;
        
        res      = h.res;
        tmpImage = h.tmpImage;
        tmpZeros = h.tmpZeros;
        currentGaborFilterPatchEven = h.currentGaborWaveletEven;
        currentGaborFilterPatchOdd  = h.currentGaborWaveletOdd;
        
        if currentScale == 1
            step = 2^(currentScale-1);
        else
            step = 2^(currentScale-1) * 3/2;
        end
        filterSize = 4 * 2^(currentScale-1);
        
        if tmp(x,y) == 0
            tmp(x,y) = 1;
            numAdded = numAdded+1;
            
            str = sprintf('%d / %d',numAdded, sizeRes);
            
            set(h.textNumAdded, 'String', str)
            
            
            if currentScale == 1
                weightEven = res{currentScale, currentOR, 2} * 2/3;
                weightOdd  = res{currentScale, currentOR, 1} * 2/3;
            else
                weightEven = res{currentScale, currentOR, 2} * 2/3;
                weightOdd  = res{currentScale, currentOR, 1} * 2/3;
            end
            
            [posX posY posX_filter posY_filter] = ...
                findFilterPosition(x,y,step,imageSize,filterSize);
            
            tmpImage(posX, posY) = tmpImage(posX, posY)...
                + weightOdd(x,y)  * currentGaborFilterPatchOdd(posX_filter, posY_filter)...
                + weightEven(x,y) * currentGaborFilterPatchEven(posX_filter, posY_filter);
            tmpZeros(posX, posY) = tmpZeros(posX, posY)...
                + weightOdd(x,y)  * currentGaborFilterPatchOdd(posX_filter, posY_filter)...
                + weightEven(x,y) * currentGaborFilterPatchEven(posX_filter, posY_filter);

            subplot(h.subplot4)
            clim = max(abs(tmpImage(:))) * [-1 1];
            imagesc(tmpImage', clim); axis xy square
            title('Sum of Gabors', 'FontSize', 14)

            subplot(h.subplot5)
            if max(abs(tmpZeros(:))) == 0;
                clim = [-1 1];
            else
                clim = max(abs(tmpZeros(:))) * [-1 1];
            end
            imagesc(tmpZeros', clim); axis xy square
            title('Wavelet Added', 'FontSize', 14)

            tmpRes{currentScale, currentOR} = tmp;
            h.tmpRes   = tmpRes;
            h.tmpImage = tmpImage;
            
            h.numAdded = numAdded;
        end

        guidata(h.figure, h)
        setSubplot232
        
    end
    drawnow

function myCallback_addNwavelets(~, ~)
    
    [~, hFigure] = gcbo;

    h = guidata(hFigure);
    
    UserData = get(h.addNwaveletsButton, 'UserData');
    if UserData.flag.interrupt == 0 && h.flag.addNwavelets == 1
        h.flag.addNwavelets = 0;
        UserData.flag.interrupt = 1;
        
        guidata(h.figure, h)
        set(h.addNwaveletsButton, 'UserData', UserData)
        
        return
    end
    
    if h.flag.showPyramid  == 1, return, end
    if h.flag.selectAll    == 1, return, end
    
    h.flag.addNwavelets = 1;
    
    guidata(h.figure, h)
    
    set(h.figure, 'WindowButtonMotionFcn', '',...
                  'WindowButtonDownFcn'  , '',...
                  'WindowButtonUpFcn'    , '')
    set(h.addNwaveletsButton, 'String', 'stop')
    
    addNumber = str2double(get(h.editaddNumber, 'String'));

    numOR    = h.param.K;
    numScale = h.param.m;
    imageSize= h.imageSize;

    tmpNumOR = numOR * 2;

    tmpRes   = h.tmpRes;
    res      = h.res;
    sizeRes  = h.sizeRes;
    tmpImage = h.tmpImage;
    tmpZeros = h.tmpZeros;

    numAdded = h.numAdded;
    
%%%%%%%%%%%%%%%%%sortRes
    % sortRes(amp; scale; OR; x; y)
    UserData = get(h.addNwaveletsButton, 'UserData');
    sortRes = UserData.sortRes;
    
    tf = isfield(h, 'ind');
    if tf == 0
        ind = 1;
    else
        ind = h.ind;
    end
    count = 1;

    pause on 
    while count <= addNumber && ind < h.sizeRes
    % while 1
        
        UserData = get(h.addNwaveletsButton, 'UserData');
        if UserData.flag.interrupt == 1
            UserData.flag.interrupt = 0;
            set(h.addNwaveletsButton, 'String', 'add N wavelets',...
                                      'UserData', UserData)
            break,
        end
    
        pauseTime = get(h.slider, 'Value');
    
        tmpGabor = tmpZeros;

        currentScale = sortRes(2,ind);
        currentOR    = sortRes(3,ind);
        x            = sortRes(4,ind);
        y            = sortRes(5,ind);

        ind = ind + 1;
        
        if tmpRes{currentScale, currentOR}(x,y) == 1, continue, end
        
        tmpRes{currentScale, currentOR}(x,y) = 1;

        numAdded = numAdded + 1;
        str = sprintf('%d / %d', numAdded, sizeRes);
        set(h.textNumAdded, 'String', str)

        h.currentOR    = currentOR;
        h.currentScale = currentScale;
        h.numAdded;

        %%%%%%%%
        figure(h.figure)
        guidata(h.figure, h)
        %%%%%%%%

        setGaborWavelet(h.figure)

        h = guidata(h.figure);
        currentGaborFilterPatchEven = h.currentGaborWaveletEven;
        currentGaborFilterPatchOdd  = h.currentGaborWaveletOdd;

        if currentScale == 1
            step = 2^(currentScale-1);
        else
            step = 2^(currentScale-1) * 3/2;
        end
        filterSize = 4 * 2^(currentScale-1);

        weightEven = res{currentScale, currentOR, 2};
        weightOdd  = res{currentScale, currentOR, 1};

        [posX posY posX_filter posY_filter] = ...
            findFilterPosition(x,y,step,imageSize,filterSize);

        tmpImage(posX, posY) = tmpImage(posX, posY)...
            + weightOdd(x,y)  * currentGaborFilterPatchOdd(posX_filter, posY_filter)...
            + weightEven(x,y) * currentGaborFilterPatchEven(posX_filter, posY_filter);
        tmpGabor(posX, posY) = tmpZeros(posX, posY)...
            + weightOdd(x,y)  * currentGaborFilterPatchOdd(posX_filter, posY_filter)...
            + weightEven(x,y) * currentGaborFilterPatchEven(posX_filter, posY_filter);


        %%%%%%
        subplot(h.subplot3)
        hold on

        ind_rho   = numScale - currentScale;
        ind_theta = currentOR-1;

        h_fillBlack = zeros([1,2]);

        for ii = 1:2
            tmp_theta = ind_theta + numOR * (ii-1);
            X = [ind_rho   /numScale*cos([2*pi * tmp_theta/tmpNumOR - pi/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR + pi/tmpNumOR]),...
                (ind_rho+1)/numScale*cos([2*pi * tmp_theta/tmpNumOR + pi/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR - pi/tmpNumOR])];
            Y = [ind_rho   /numScale*sin([2*pi * tmp_theta/tmpNumOR - pi/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR + pi/tmpNumOR]),...
                (ind_rho+1)/numScale*sin([2*pi * tmp_theta/tmpNumOR + pi/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR,...
                                          2*pi * tmp_theta/tmpNumOR - pi/tmpNumOR])];

            delete(h.fillBlack(ii));                          
            h_fillBlack(ii) = fill(X,Y,[0,0,0]);
        end
        h.fillBlack = h_fillBlack;

        hold off


        %%%%%
        subplot(h.subplot4)
        clim = max(abs(tmpImage(:))) * [-1 1];
        imagesc(tmpImage', clim); axis xy square
        title('Sum of Gabors', 'FontSize', 14)

        subplot(h.subplot5);
        if max(abs(tmpGabor(:))) == 0;
            clim = [-1 1];
        else
            clim = max(abs(tmpGabor(:))) * [-1 1];
        end
        imagesc(tmpGabor', clim); axis xy square
        title('Wavelet Added', 'FontSize', 14)


        count = count + 1;
        drawnow;
        pause(pauseTime)
        

        
    end
    pause off

    h.flag.addNwavelets = 0;
    set(h.addNwaveletsButton, 'String', 'add N wavelets')
    
    h.tmpRes   = tmpRes;
    h.tmpImage = tmpImage;
    h.ind      = ind;

    h.numAdded = numAdded;

    guidata(h.figure, h)

    set(h.figure, 'WindowButtonMotionFcn', @myCallback_ButtonMotion,...
                  'WindowButtonDownFcn'  , @myCallback_ButtonDown,...
                  'WindowButtonUpFcn'    , @myCallback_ButtonUp)
                  
function myCallback_loadButton(~,~)
    [~, hFigure] = gcbo;
    h = guidata(hFigure);
    if h.flag.addNwavelets == 1, return, end
    if h.flag.showPyramid  == 1, return, end
    if h.flag.selectAll    == 1, return, end
    
    GaborWaveletRepresentation

function myCallback_ButtonDown(~,~)
    [~, hFigure] = gcbo;

    h = guidata(hFigure);
    
    [pos] = get(h.figure, 'CurrentPoint');
    
    if abs( pos(1) - 3/6) < 1/6 && pos(2) > 1/2      % mouse is on the subplot232
        
        % show and add the gabor of the current mouse positioin using
        % callback function instead of making other function
        myCallback_ButtonMotion2
        
        set(h.figure, 'WindowButtonMotionFcn', '')
        set(h.figure, 'WindowButtonMotionFcn', @myCallback_ButtonMotion2)
  
        
    elseif abs(pos(1) - 5/6) < 1/6 && pos(2) > 1/2    % mouse is on the subplot233
        
        tmpPos = get(h.subplot3, 'CurrentPoint');   % get the mouse position on the subplot233 axis
        x = tmpPos(1,1,1); y = tmpPos(1,2,1);
        rho   = sqrt(x^2 + y^2);  % radius
 
        if rho <= 1 
            setCurrentGaborWavelet
            setGaborWavelet(h.figure)
            drawBlackFill
            setSubplot232
        end
    end
    
function myCallback_ButtonUp(~,~)
    [~, hFigure] = gcbo;

    h = guidata(hFigure);
    set(h.figure, 'WindowButtonMotionFcn', @myCallback_ButtonMotion)

function myCallback_resetButton(~, ~)
    
    [~, hFigure] = gcbo;
    
    h = guidata(hFigure);
    if h.flag.addNwavelets == 1, return, end
    if h.flag.showPyramid  == 1, return, end
    if h.flag.selectAll    == 1, return, end
    
    h.ind = 1;
    h.numAdded = 0;
    
    str = sprintf('%d / %d', h.numAdded, h.sizeRes);
    set(h.textNumAdded, 'String', str)
    guidata(h.figure, h)
    
    initializeTmpRes
    initializeTmpImage
    setSubplot232
    
function myCallback_selectAll(~, ~)
    [~, hFigure] = gcbo;

    h = guidata(hFigure);
    
    if h.flag.addNwavelets == 1, return, end
    if h.flag.showPyramid  == 1, return, end
    if h.flag.selectAll    == 1, return, end
    
    set(h.figure, 'WindowButtonMotionFcn', '',...
                  'WindowButtonDownFcn'  , '',...
                  'WindowButtonUpFcn'    , '')

    
    h.flag.selectAll = 1;
    guidata(h.figure, h);
    
    set(h.figure, 'WindowButtonMotionFcn', '')
    
    currentScale = h.currentScale;
    currentOR    = h.currentOR;

    sizeRes      = h.sizeRes;
    tmpRes       = h.tmpRes;
    tmp          = tmpRes{currentScale, currentOR};
    
    
    numAdded = h.numAdded;
    
    imageSize= h.imageSize;
        
    res      = h.res;
    tmpImage = h.tmpImage;

    currentGaborFilterPatchEven = h.currentGaborWaveletEven;
    currentGaborFilterPatchOdd  = h.currentGaborWaveletOdd;

    if currentScale == 1
        step = 2^(currentScale-1);
    else
        step = 2^(currentScale-1) * 3/2;
    end
    filterSize = 4 * 2^(currentScale-1);

    weightEven = res{currentScale, currentOR, 2};
    weightOdd  = res{currentScale, currentOR, 1};

    for x = 1: size(tmp,1)
        for y = 1: size(tmp,2)

            if tmp(x,y) == 0
                tmp(x,y) = 1;
                
                numAdded = numAdded + 1;
                
                [posX posY posX_filter posY_filter] = ...
                    findFilterPosition(x,y,step,imageSize,filterSize);

                tmpImage(posX, posY) = tmpImage(posX, posY)...
                    + weightOdd(x,y)  * currentGaborFilterPatchOdd(posX_filter, posY_filter)...
                    + weightEven(x,y) * currentGaborFilterPatchEven(posX_filter, posY_filter);
            end
        end
    end
    
    str = sprintf('%d / %d', numAdded, sizeRes);
    set(h.textNumAdded, 'String', str)
                

    subplot(h.subplot4)
    clim = max(abs(tmpImage(:))) * [-1 1];
    imagesc(tmpImage', clim); axis xy square
    title('Sum of Gabors', 'FontSize', 14)
    drawnow

    tmpRes{currentScale, currentOR} = tmp;
    h.tmpRes   = tmpRes;
    h.tmpImage = tmpImage;
    
    h.numAdded = numAdded;
    
    h.flag.selectAll = 0;
    
    guidata(h.figure, h)
    setSubplot232
    
    set(h.figure, 'WindowButtonMotionFcn', @myCallback_ButtonMotion,...
                  'WindowButtonDownFcn'  , @myCallback_ButtonDown,...
                  'WindowButtonUpFcn'    , @myCallback_ButtonUp)

function myCallback_showPyramidButton(~,~)
    [~, hFigure] = gcbo;
    h = guidata(hFigure);
    
    if h.flag.addNwavelets == 1, return, end
    if h.flag.showPyramid  == 1, return, end
    if h.flag.selectAll    == 1, return, end

    h.flag.showPyramid = 1;
    
    guidata(h.figure, h)

    set(h.figure, 'WindowButtonMotionFcn', '',...
                  'WindowButtonDownFcn'  , '',...
                  'WindowButtonUpFcn'    , '')
    
    h.figure2 = figure(2); clf;
    
    powerMap = h.powerMap;
    numScale = h.param.m;
    numOR    = h.param.K;
    
    normalizeEachScale = get(h.normalizeCheckbox, 'Value');
    
    amp = powerMap;

    if h.flag.ampNormalize == 0
        for scale = 1: numScale
            for kk = 1: numOR
                amp{scale, kk} = sqrt(powerMap{scale, kk});
            end
        end
    elseif h.flag.ampNormalize == 1
        for scale = 1: numScale
            for kk = 1: numOR
                if scale == 1
                    amp{scale, kk} = sqrt(powerMap{scale, kk}) * 2^(numOR - scale) * 2/3;
                else
                    amp{scale, kk} = sqrt(powerMap{scale, kk}) * 2^(numOR - scale);
                end
            end
        end
    end
        
        
    a0 = numScale-1;
    h_waitbar = waitbar(0, 'Now drawing...');
    
    tmpMaxAll = 0;
    for scale = 2: numScale
        for kk = 1: numOR
            tmp = amp{scale, kk};

            if max(tmp(:)) > tmpMaxAll
                 tmpMaxAll = max(tmp(:));
            end
        end
    end

    for scale = numScale:-1:2
        figure(h.figure2);


        if normalizeEachScale == 1
            tmpMax = 0;
            for kk = 1: numOR
                tmp = amp{scale, kk};

                if max(tmp(:)) > tmpMax 
                     tmpMax = max(tmp(:));
                end
            end
        else
            tmpMax = tmpMaxAll;
        end


        subplot(2,floor(numScale/2),numScale-scale + 1)

        tmp = amp{scale, 1};
        tmpSize = size(tmp);
        x = 0:tmpSize(1);
        y = 0:tmpSize(2);

        step = (x(2) - x(1))/2;
        ctrX = x(1:end-1) + 2*step;
        ctrY = y(1:end-1) + 2*step;
        hold on

        for kk = 1: numOR
            tmp = amp{scale, kk};

            for ii = 1: tmpSize
                for jj = 1: tmpSize

                    OR = pi/2 + pi/numOR * (kk-1) + [pi/numOR -pi/numOR]/2;

                    if OR(1) > pi/4  && OR(1) < pi*3/4 &&...
                            OR(2) > pi/4  && OR(2) < pi*3/4
                        xx = [1/tan(OR(1)), 1/tan(OR(2)), -1/tan(OR(2)), -1/tan(OR(1))] / 2;
                        yy = [1,1,-1,-1]/2;
                    elseif OR(1) > 3/4 * pi && OR(2) < 3/4 * pi
                        xx = [-1, -1, 1/tan(OR(2)), -1/tan(OR(2)), 1, 1]/2;
                        yy = [-tan(OR(1)), 1, 1, -1, -1, tan(OR(1))]/2;
                    elseif OR(1) > 3/4 * pi && OR(1) < 5/4 * pi &&...
                            OR(2) > 3/4 * pi && OR(2) < 5/4 * pi
                        xx = [1, 1, -1, -1]/2;
                        yy = [tan(OR(1)), tan(OR(2)), -tan(OR(2)), -tan(OR(1))] / 2;
                    elseif OR(1) > 5/4 * pi && OR(2) < 5/4 * pi
                        xx = [-1/tan(OR(1)), -1, -1, 1, 1, 1/tan(OR(1))]/2;
                        yy = [-1, -1, -tan(OR(2)), tan(OR(2)), 1, 1]/2;
                    elseif OR(1) > 5/4 * pi && OR(2) > 5/4 * pi
                        xx = [1/tan(OR(1)), 1/tan(OR(2)), -1/tan(OR(2)), -1/tan(OR(1))] / 2;
                        yy = [1,1,-1,-1]/2;
                    end
                    currentColor = [1,1,1] - tmp(ii,jj) / tmpMax * [0,1,1];
                    fill(xx + ctrX(ii), yy + ctrY(jj), currentColor, 'edgeColor', currentColor)        

                end
            end
        end

        currentSF = 2^(numScale - scale);
        title([num2str(currentSF) 'cyc/FOV'], 'FontSize', 14)
        axis tight square

        box on
        set(gca, 'LineWidth', 2)
  
        waitbar((scale-1) / a0);

    end
    close(h_waitbar);
  
    h.flag.showPyramid = 0;
    guidata(h.figure, h)
    
    set(h.figure, 'WindowButtonMotionFcn', @myCallback_ButtonMotion,...
                  'WindowButtonDownFcn'  , @myCallback_ButtonDown,...
                  'WindowButtonUpFcn'    , @myCallback_ButtonUp)

    
function setGaborWavelet(hFigure)

    h = guidata(hFigure);

    imageSize = h.imageSize;
    if h.flag.setGabor == 0
        % mouse cursor is out of the subplot 233
        ind_scale = h.currentScale;
        ind_OR    = h.currentOR;
    elseif h.flag.setGabor == 1
        % mouse cursor is in the subplot 233
        ind_scale = h.ind_scale;
        ind_OR    = h.ind_OR;
    end
        
        
    param = h.param;

    filterSize = 4 * 2^(ind_scale-1);
    tx = 1:filterSize;
    ty = 1:filterSize;
    [x,y] = meshgrid(tx,ty); x = x'; y = y';
    ctr = ( 4 + 2^(-(ind_scale-1)) ) / 2;
    
    tmpGaborFilterPatchEven = GaborWavelet(x,y, ind_scale-1,ctr,ctr,ind_OR-1, param, 0);
    tmpGaborFilterPatchOdd  = GaborWavelet(x,y, ind_scale-1,ctr,ctr,ind_OR-1, param, 1);
    patchPos = (imageSize - filterSize)/2 + 1 : (imageSize + filterSize)/2;
    if size(tmpGaborFilterPatchEven,1) > imageSize
        tmpPos = (length(tx) - imageSize)/2+1 : (length(tx) - imageSize)*3/2;
        tmpGaborFilterPatchEven = tmpGaborFilterPatchEven(tmpPos, tmpPos);
        tmpGaborFilterPatchOdd  = tmpGaborFilterPatchOdd(tmpPos, tmpPos);
        patchPos = 1:imageSize;
    end
    
    h.currentGaborWaveletEven = tmpGaborFilterPatchEven;
    h.currentGaborWaveletOdd  = tmpGaborFilterPatchOdd;
    
    h.tmpGaborFilterPatch = tmpGaborFilterPatchEven;
    
    tmpGaborFilter2 = h.tmpZeros;
    
    tmpGaborFilter2(patchPos, patchPos) = tmpGaborFilter2(patchPos, patchPos) + tmpGaborFilterPatchEven; 
    
    guidata(h.figure, h);
    
    if h.flag.addNwavelets == 0
        subplot(h.subplot6)
        clim = max(abs(tmpGaborFilter2(:))) * [-1 1];
        imagesc(tmpGaborFilter2', clim);
        axis xy square
        title('Selected Gabor Wavelet', 'FontSize', 14)
    end

function setCurrentGaborWavelet

    h = guidata(gcf);
    currentOR    = h.ind_OR;
    currentScale = h.ind_scale;
    currentInd_rho   = h.ind_rho;
    currentInd_theta = h.ind_theta;
    

    h.currentInd_rho   = currentInd_rho;
    h.currentInd_theta = currentInd_theta;
    h.currentOR    = currentOR;
    h.currentScale = currentScale;
    guidata(h.figure, h)
    
function drawBlackFill

    h = guidata(gcf);
    numOR    = h.param.K;
    numScale = h.param.m;
    ind_rho   = h.currentInd_rho;
    ind_theta = h.currentInd_theta;

    subplot(h.subplot3)
    hold on
    
    h_fillBlack = zeros([1,2]);
 
    for ii = 1: 2
        tmp_theta = ind_theta + numOR * (ii-1);
        X = [ind_rho   /numScale*cos([pi * tmp_theta/numOR - pi/numOR/2,...
                                      pi * tmp_theta/numOR,...
                                      pi * tmp_theta/numOR + pi/numOR/2]),...
            (ind_rho+1)/numScale*cos([pi * tmp_theta/numOR + pi/numOR/2,...
                                      pi * tmp_theta/numOR,...
                                      pi * tmp_theta/numOR - pi/numOR/2])];
        Y = [ind_rho   /numScale*sin([pi * tmp_theta/numOR - pi/numOR/2,...
                                      pi * tmp_theta/numOR,...
                                      pi * tmp_theta/numOR + pi/numOR/2]),...
            (ind_rho+1)/numScale*sin([pi * tmp_theta/numOR + pi/numOR/2,...
                                      pi * tmp_theta/numOR,...
                                      pi * tmp_theta/numOR - pi/numOR/2])];

    
        delete(h.fillBlack(ii))

        h_fillBlack(ii) = fill(X,Y,[0,0,0]);
    end
    hold off
    
    h.fillBlack = h_fillBlack;
    % flag to check the gavor setting
    h.flag.setGabor = 1;

    guidata(h.figure, h)

function setSubplot232
    
    h = guidata(gcf);
    
    currentOR    = h.currentOR;
    currentScale = h.currentScale;
    
    tmpRes       = h.tmpRes;
    currentRes   = tmpRes{currentScale, currentOR};
    
    subplot(h.subplot2)
    lengthx = length(currentRes(:,1));
    lengthy = length(currentRes(1,:));
    
    x = 1 :lengthx;
    y = 1: lengthy;
    imagesc(x, y, currentRes', [0,1]);
    axis xy square
    title('Position Select' , 'FontSize', 14)
    
function initializeTmpRes
    h = guidata(gcf);
    
    res = h.res;
    tf = isfield(h, 'tmpRes');
    
    if tf == 0
        res1   = cell([size(res),2]);
        tmpRes = cell(size(res));
        powerMap = cell(size(res));
        for scale = 1: size(tmpRes,2)
            for OR = 1: size(tmpRes,1)
                tmpOdd = res(OR,scale).odd;
                res1{OR,scale,1}   = tmpOdd;
                
                tmpEven = res(OR,scale).even;
                res1{OR,scale,2}   = tmpEven;
                
                powerMap{OR,scale} = tmpEven.^2 + tmpOdd.^2;
                tmpRes{OR,scale} = zeros(size(tmpOdd));
            end
        end
        
        % change the form of "res"
        h.res    = res1;   % res{scale, OR, phase}
        h.tmpRes = tmpRes;
        h.powerMap = powerMap;

    elseif tf == 1
        
        numOR    = h.param.K;
        numScale = h.param.m;

        tmpRes = h.tmpRes;
        for OR = 1:numOR
            for scale = 1: numScale
                tmpRes{scale,OR}(:,:) = 0;
            end
        end
        
    h.tmpRes = tmpRes;
  
    end
    
    guidata(h.figure, h)

function initializeTmpImage
    h = guidata(gcf);
    imageSize = h.imageSize;
    tmpZeros   = zeros(imageSize);
    tmpImage = zeros(imageSize);

    subplot(h.subplot4)
    imagesc(tmpImage'); axis xy square
    title('Sum of Gabors', 'FontSize', 14)

    subplot(h.subplot5)
    if max(abs(tmpZeros(:))) == 0;
        clim = [-1 1];
    else
        clim = max(abs(tmpZeros(:))) * [-1 1];
    end
    imagesc(tmpZeros', clim); axis xy square
    title('Wavelet Added', 'FontSize', 14)

    h.tmpZeros = tmpZeros;
    h.tmpImage = tmpImage;
    
    guidata(h.figure, h);
    
function [posX posY posX_filter posY_filter] = ...
                    findFilterPosition(x,y,step,imageSize,filterSize)
    
    numFilter = ceil(((imageSize(1) - filterSize(1))/2 + 1)/step) * 2 + 1;
    tmpImageSize = step * (numFilter - 1) + filterSize(1);
    
    offset = - (tmpImageSize - imageSize) / 2;
    filterLength = 1: filterSize(1);
    
    posX = offset + step * (x-1) + filterLength;
    if 1 <= min(posX) && max(posX) <= imageSize
        posX_filter = filterLength;
    elseif min(posX) < 1
        posX(posX < 1) = [];
        posX_filter = filterSize(1) - length(posX) + 1: filterSize(1);
    elseif max(posX) > imageSize
        posX(posX > imageSize) = [];
        posX_filter = 1:length(posX);
    end
    
    posY = offset + step * (y-1) + filterLength;

    if 1 <= min(posY) && max(posY) <= imageSize
        posY_filter = filterLength;
    elseif min(posY) < 1
        posY(posY < 1) = [];
        posY_filter = filterSize(1) - length(posY) + 1: filterSize(1);
    elseif max(posY) > imageSize
        posY(posY > imageSize) = [];
        posY_filter = 1:length(posY);

    end
    
    if length(posX) > imageSize
        posX = 1: imageSize;
        posY = 1: imageSize;
        posX_filter = 1: imageSize;
        posY_filter = 1: imageSize;
    end

function sortWavelets
    
    h = guidata(gcf);

    powerMap = h.powerMap;
    numScale = h.param.m;
    numOR    = h.param.K;
    
    sizeTmp = 0;
    
    for scale = 1: numScale
        sizeTmp = sizeTmp * size(powerMap{scale,1}, 1) ^ 2;
    end
    
    tmp = zeros([5, sizeTmp * numOR]);
        
    ind = 0;
        
    for scale = 1: numScale
        
        currentSize = size(powerMap{scale,1});
        for OR = 1: numOR
            for x = 1: currentSize(1)
                for y = 1: currentSize(2)
                    ind = ind+1;
                    tmp(1,ind) = powerMap{scale,OR}(x,y);
                    tmp(2,ind) = scale;
                    tmp(3,ind) = OR;
                    tmp(4,ind) = x;
                    tmp(5,ind) = y;
                end
            end
        end
    end
    
    [B, IX] = sort(tmp(1,:), 'descend');
    
    sortRes = zeros(size(tmp));
    sortRes(1,:) = B;
    sortRes(2,:) = tmp(2,IX);
    sortRes(3,:) = tmp(3,IX);
    sortRes(4,:) = tmp(4,IX);
    sortRes(5,:) = tmp(5,IX);
    
    UserData = get(h.addNwaveletsButton, 'UserData');
    UserData.sortRes = sortRes;
    set(h.addNwaveletsButton, 'UserData', UserData)
    
function setSizeGaborWavelet
    
    h = guidata(gcf);
    numScale = h.param.m;
    numOR    = h.param.K;
    
    powerMap = h.powerMap;
    
    sizeRes = 0;
    
    for scale = 1: numScale
        sizeRes = sizeRes + size(powerMap{scale,1}, 1) ^ 2;
    end
    
    sizeRes = sizeRes * numOR;
    
    h.sizeRes = sizeRes;
    
    str = sprintf('%d / %d', 0, sizeRes);
    
    set(h.textNumAdded, 'String',str)
    
    guidata(h.figure, h);
    
