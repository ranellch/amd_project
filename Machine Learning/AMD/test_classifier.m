function [ output ] = test_classifier( filenames, model, testname, row, resize )
%REQUIRES: filenames is a numimages x 4 cell array of strings consisting of: [identifier, late image filename,  labeled image filename]
%          model is a previously generated adaboost model
%          testname is the name of the output image folder and excel file specifying where test results will be written
%          row is the line below header where writing begins in excel
%          resize is bool,true for scaling to 768 by 768
%MODIFIES:  directory named "testname" is created with classified images
%           "output" array is written to testname.xlsx within testname directory showing statistical data     
%EFFECTS: return output - array of filenames and associated sensitivities
%(true positive rates tp/p), specificities (true negative rates tn/n),
%accuracies (tp+tn)/(p+n), and precision tp/(tp+fp)
addpath(genpath('../ML Library'));
addpath('./pics');

testdir=testname;
if ~isdir(testdir)
    mkdir(testdir)
end

xlname=['./',testname, '/', testname, '.xlsx'];
if row == 0
    header={'Image','Sensitivity','Specificity','Accuracy', 'Precision'};
    xlwrite(xlname, header);
end

output=cell(size(filenames,1),5);

for i=1:size(filenames,1)
    I=imread(filenames{i,2});
    Ilabeled = imread(filenames{i,3});
    if size(Ilabeled,3)>3
        Ilabeled=Ilabeled(:,:,1:3);
    end
    Ilabeled = crop_footer(Ilabeled);
    if resize
        Ilabeled=imresize(Ilabeled, [768 768]);
    end
    disp('======================================================');
    disp(['Classifying image ', filenames{i,1}]);
    tic
    [Iout,Ibin] = classify_pixels(I,model);
    toc
    %Save output images 
    imwrite(Iout,['./',testdir,'/classified ', filenames{i,1}, '.tif'],'tiff');
    imwrite(Ibin,['./',testdir,'/binary ', filenames{i,1}, '.tif'],'tiff'); 
    %Run stats
    testpos=Iout(:,:,1)>Iout(:,:,2);
    pos = Ilabeled(:,:,1)>Ilabeled(:,:,2);
    %Get number of red pixels in user colored image
    numpos = nnz(pos); 
    %Get number of negative pixels
    numneg = nnz(~pos); 
    %Compare red pixels in user labeled image and classified images
    truepos = pos & testpos; 
    falsepos = ~pos & testpos;
    trueneg = ~pos & ~testpos;
    num_tp = nnz(truepos);
    num_fp = nnz(falsepos);
    num_tn = nnz(trueneg);
    sensitivity = num_tp/numpos;
    specificity = num_tn/numneg;
    accuracy = (num_tp+num_tn)/numel(Iout(:,:,1));
    disp(['Accuracy: ', num2str(accuracy)]);
    precision = num_tp/(num_tp+num_fp);
    output{i,1}=filenames{i,1};
    output{i,2}=sensitivity;
    output{i,3}= specificity;
    output{i,4}=accuracy;
    output{i,5}=precision;
    xlwrite(xlname,output(i,:),['A',int2str(row+i+1),':','E',int2str(row+i+1)]);
end

end



