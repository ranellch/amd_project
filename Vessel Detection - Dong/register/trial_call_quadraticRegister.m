close all
clear
clc

datapath = 'D:\Dropbox\Eye Image Analysis\DME project\data\JDRF-001\1 year';
timings = xlsread(fullfile(datapath, 'timing')); 

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(2,:), datapath);

[img_early, ophth_acquis_context_early] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(1,:), datapath);

% [img_early, img_late] = normalizePixelSize(img_early, ophth_acquis_context_early, img_late, ophth_acquis_context_late);

% % image pyramid
% pyramid_level = 5;
% early_pyramid = produceImPyramid(img_early, pyramid_level);
% late_pyramid = produceImPyramid(img_late, pyramid_level);

img_early = imresize(img_early, .25);
img_late = imresize(img_late, .25);

[Tx, Ty] = manualTranslationRegister(img_early, img_late);
[theta] = quadraticRegister(img_early, img_late, Tx, Ty);

disp('Program exited.');

