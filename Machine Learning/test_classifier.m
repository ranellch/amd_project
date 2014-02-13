function [ output ] = test_classifier( filenames, model, testname )
%REQUIRES: filenames is a numimages x 2 cell array of strings consisting of: [original image filename,  colored counterpart]
%          model is a previously generated adaboost model
%          testname is the name of the output image folder and excel file specifying where test results will be written
%MODIFIES:  directory named "testname" is created with classified images
%           "output" array is written to testname.xlsx within testname directory showing statistical data     
%EFFECTS: return output - array of filenames and associated sensitivities
%(true positive rates tp/p), specificities (true negative rates tn/n),
%accuracies (tp+tn)/(p+n), and precision tp/(tp+fp)
testdir=testname;
mkdir(testdir)
output=cell(size(filenames,1),5);
output(1,1:5)={'File','Sensitivity','Specificity','Accuracy', 'Precision'};
xlname=['./',testname, '/', testname, '.xlsx'];
xlwrite(xlname, output(1,:));
for i=1:size(filenames,1)
    I=imread(filenames{i,1});
    Ilabeled = imread(filenames{i,2});
    [Iout,~] = classify_pixels(I,model);
    imwrite(Iout,['./',testdir,'/classified ', filenames{i,1}],'tiff');
    pos = Ilabeled(:,:,1)>Ilabeled(:,:,2);
    testpos=Iout(:,:,1)>Iout(:,:,2);
    numpos = nnz(pos); %get number of red pixels in user colored image
    numneg = nnz(~pos); %get number of negative pixels
    %compare red pixels in user labeled image and classified images
    truepos = pos & testpos; 
    falsepos = ~pos & testpos;
    trueneg = ~pos & ~testpos;
    num_tp = nnz(truepos);
    num_fp = nnz(falsepos);
    num_tn = nnz(trueneg);
    sensitivity = num_tp/numpos;
    specificity = num_tn/numneg;
    accuracy = (num_tp+num_tn)/numel(Iout(:,:,1));
    precision = num_tp/(num_tp+num_fp);
    output{i+1,1}=filenames{i,1};
    output{i+1,2}=sensitivity;
    output{i+1,3}= specificity;
    output{i+1,4}=accuracy;
    output{i+1,5}=precision;
    xlwrite(xlname,output(i+1,:),['A',int2str(i+1),':','E',int2str(i+1)]);
end

end



