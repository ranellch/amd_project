close all
clear
clc

alldatafolder = 'C:\Users\Dong\Documents\Dropbox\Eye Image Analysis\DME project\data';
% alldatafolder = 'D:\Dropbox\Eye Image Analysis\DME project\data';

pID = 'JDRF-003';
visit = '6 month';
refID = 'Dr.J';
datapath = fullfile(alldatafolder, pID, visit);
timings = xlsread(fullfile(datapath, 'timing'));

[img_late, ophth_acquis_context_late] = loadSpecifiedDelayFAinXMLdatabase...
    (timings(3,:), datapath);
if size(img_late, 1)>768
    img_late = imresize(img_late, .5);
end

loadpath = fullfile(alldatafolder, 'feature_n_label_storage', ...
    sprintf('%s %s %s labels.mat', pID, visit, refID));
load(loadpath);

figure
imshowpair(img_late, reflabel, 'blend');
maximize

