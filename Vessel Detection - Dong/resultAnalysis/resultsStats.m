% 

% starting with cleaning works
clear
clc

% find lists of auto and manual results
result_folder = 'D:\Dropbox\Eye Image Analysis\abstract\dataInUse';
list_mask = dir([result_folder '\*binary*']);
list_refC = dir([result_folder '\*DrC*']);
list_refJ = dir([result_folder '\*DrJ*']);

num_pair = length(list_mask);
resultID = cell(num_pair,1);
DC_mask_refC = zeros(num_pair,1);
DC_mask_refJ = zeros(num_pair,1);
DC_refC_refJ = zeros(num_pair,1);
area_mask = zeros(num_pair,1);
area_refC = zeros(num_pair,1);
area_refJ = zeros(num_pair,1);
for i = 1:num_pair
    resultID{i} = list_mask(i).name(1:end-11);
    
    path_mask = [result_folder '\' list_mask(i).name];
    mask = imread(path_mask);
    mask = mask>0;
    area_mask(i) = sum(mask(:));
    
    path_refC = [result_folder '\' list_refC(i).name];
    refC = imread(path_refC);
    size_record = crop_footer(refC(:,:,1));
    % convert red filled reference result to binary mask as well
    refC_mask = (refC(:,:,1)>.9*255) & ...
        (refC(:,:,2)<.1*255) & (refC(:,:,3)<.1*255);
    refC_mask = refC_mask(1:size(size_record,1), 1:size(size_record,2));
    refC_mask = imresize(refC_mask, size(mask), 'nearest');
    area_refC(i) = sum(refC_mask(:));
    
    path_refJ = [result_folder '\' list_refJ(i).name];
    refJ = imread(path_refJ);
    size_record = crop_footer(refJ(:,:,1));
    % convert red filled reference result to binary mask as well
    refJ_mask = (refJ(:,:,1)>.9*255) & ...
        (refJ(:,:,2)<.1*255) & (refJ(:,:,3)<.1*255);
    refJ_mask = refJ_mask(1:size(size_record,1), 1:size(size_record,2));
    refJ_mask = imresize(refJ_mask, size(mask), 'nearest');
    area_refJ(i) = sum(refJ_mask(:));
    
    DC_mask_refC(i) = DiceCoefficientFromBinaryMasks(mask, refC_mask);
    DC_mask_refJ(i) = DiceCoefficientFromBinaryMasks(mask, refJ_mask);
    DC_refC_refJ(i) = DiceCoefficientFromBinaryMasks(refC_mask, refJ_mask);
end

% save results to excel 
% Dice coefficients
xlswrite([result_folder '\results.xlsx'], ... % header
    {'refC vs refJ', 'auto vs refC', 'auto vs refJ'}, 'DC', 'B1');
xlswrite([result_folder '\results.xlsx'], resultID, 'DC', 'A2'); % left sider
xlswrite([result_folder '\results.xlsx'], DC_refC_refJ, 'DC', 'B2');
xlswrite([result_folder '\results.xlsx'], DC_mask_refC, 'DC', 'C2');
xlswrite([result_folder '\results.xlsx'], DC_mask_refJ, 'DC', 'D2');
% absolute areas measure in number of pixels
xlswrite([result_folder '\results.xlsx'], ... % header
    {'auto', 'refC', 'refJ'}, 'Absolute_area', 'B1');
xlswrite([result_folder '\results.xlsx'], resultID, 'Absolute_area', 'A2');
xlswrite([result_folder '\results.xlsx'], area_mask, 'Absolute_area', 'B2');
xlswrite([result_folder '\results.xlsx'], area_refC, 'Absolute_area', 'C2');
xlswrite([result_folder '\results.xlsx'], area_refJ, 'Absolute_area', 'D2');

