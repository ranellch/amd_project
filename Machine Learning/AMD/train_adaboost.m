function [ model ] = train_adaboost( modelname, testname, filenames, itt, test, resize )
%REQUIRES: modelname is a string specifying what to save the model as,
%           testname is also a string
%   filenames is a numimages x 4 cell array of strings consisting of: [identifier, late image filename,  labeled image filename]
%           itt is the number of training iterations used to build
%           classifier model
%           test is bool determining whether or not to show training
%           results on single image
%           resize is bool determining whether or not to scale to 768 by
%           768
%EFFECTS: Returns model - struct consisting of weighted feature classifier
%           model using adaboost
addpath(genpath('../ML Library'));
addpath('./pics');
addpath(genpath('./models'));

dataset = [];
all_classes = [];
%parse filenames, build dataset
for i = 1:size(filenames,1)
    I = imread(filenames{i,2});
    Icolored = imread(filenames{i,3});
    Iearly = imread(filenames{i,4});
    disp(['Obtaining feature vectors for image ', filenames{i,1}])
    tic
    [datafeatures, dataclass] = get_training_data(I, Icolored, resize);
    toc
    dataset = [dataset; datafeatures];
    all_classes = [all_classes; dataclass];
end

%build model with adaboost
disp('===============================================================');
disp('Building adaboost model')
tic
[estimateclass,model] = adaboost('train', dataset, all_classes, itt);
toc
% weak_learner = tree_node_w(3);
% [Learners, Weights, final_hyp] = ModestAdaBoost(weak_learner, dataset', all_classes', itt);

%Save model
if ~isdir(['./models/', testname])
    mkdir(['./models/',testname]);
end
save(['./models/', testname, '/', modelname,'.mat'], 'model','filenames');
    
if test 
    %look at last image
    
    [h,w]=size(I);
    
    classes = zeros(size(I));
    for i = 1:h
        for j = 1:w
            index = (i-1)*w+j;
            classes(i,j)= estimateclass(index);
        end
    end


     % Show result
    [Iind,map] = gray2ind(I,256);
    Irgb=ind2rgb(Iind,map);
    Ihsv = rgb2hsv(Irgb);
    hueImage = Ihsv(:,:,1);
    hueImage(classes==1) = 0.011; %red
    Ihsv(:,:,1) = hueImage;
    satImage = Ihsv(:,:,2);
    satImage(classes==1) = .8; %semi transparent
    Ihsv(:,:,2) = satImage;
    Iout = hsv2rgb(Ihsv);

    figure, imshow(Iout)
end

end

