function [ model ] = train_adaboost( modelname, testname, filenames, itt, disp, resize )
%REQUIRES: modelname is a string specifying what to save the model as,
%           testname is also a string
%   filenames is a numimages x 3 cell array of strings consisting of: [identifier, image filename,  labeled image filename]
%           itt is the number of training iterations used to build
%           classifier model
%           test is bool determining whether or not to show training
%           results on single image
%           resize is bool determining whether or not to scale to 768 by
%           768
%EFFECTS: Returns model - struct consisting of weighted feature classifier
%           model using adaboost

addpath(genpath('../ML Library'));
addpath(genpath('../Test Set/'));
addpath(genpath('./models'));

dataset = [];
all_classes = [];
%parse filenames, build dataset
for i = 1:size(filenames,1)
    I = imread(filenames{i,2});
    Icolored = imread(filenames{i,3});
    %run preprocessing
    [I, Ilabeled, featuremask] = preprocess(I, Ilabeled, resize);    
    disp(['Obtaining feature vectors for image ', filenames{i,1}])
    tic
    [datafeatures, dataclass] = get_training_data(I, Icolored, featuremask);
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
    
if disp 
    %look at first image
    I = imread(filenames{1,2});
    if resize
        I = imresize(I, [768 768]);
    end

    classes = zeros(size(I));
    classes(~featuremask) = estimateclass(1:numel(~featuremask));

     % Show result
    Iout = display_mask(I,classes);

    figure, imshow(Iout)
end

end

