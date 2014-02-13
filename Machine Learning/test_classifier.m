function [ output ] = test_classifier( filenames, model, xlname )
%REQUIRES: filenames is a numimages x 2 cell array of strings consisting of: [original image filename,  colored counterpart]
%          model is a previously generated adaboost model
%          xlname is the name of an excel file specifying where to write test results
%MODIFIES: xlname is edited to show accuracies 
%          (# of pixels classified/# of colored pixels) next to filenames          
%EFFECTS: returns array of filenames and associated accuracies
output=cell(size(filenames,1),2);
for i=1:size(filenames,1)
    I=imread(filenames{i,1});
    Ilabeled = imread(filenames{i,2});
    [Iout,~] = classify_pixels(I,model);
    imwrite(Iout,['./',datestr(clock, 0),'/classified ', filenames{i,1}],'tiff');
    numpos = nnz(Ilabeled(:,:,1)>Ilabeled(:,:,2)); %get number of red pixels in user colored image
    overlap = Ilabeled(:,:,1)>Ilabeled(:,:,2) & Iout(:,:,1)>Iout(:,:,2); %compare red pixels in user labeled image and classified images
    output{i,1}=filenames{i,1};
    output{i,2}=nnz(overlap)/numpos;
end
xlwrite(xlname,output);
end



