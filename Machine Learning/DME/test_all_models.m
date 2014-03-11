[~,allimages,~] = xlsread('usable FA list.xlsx');
testname = '10 Image Model - DME Abstract Results';
allimages = allimages(2:end,:); %ignore header
numimages = size(allimages,1);
itt = 30;
for i = 1:1
    
    tester=allimages(i,:);
    modelname=tester{1}; %name each model after image that will be tested
    
    rowindex=ones(numimages,1);
    rowindex(i)=0;
    trainers = allimages(rowindex~=0,:);
    
    disp('New model with images:')
    disp(trainers(1,:))
    model = train_adaboost( modelname, trainers, itt, 0, 1 );
    test_classifier( tester, model, testname, i-1 );
end

