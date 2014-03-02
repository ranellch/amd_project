function [ model ] = train_adaboost( filenames, itt, test, resize )
%REQUIRES: filenames is a numimages x 2 cell array of strings consisting of: [original image file,  colored counterpart]
%           itt is the number of training iterations used to build
%           classifier model
%           test is bool determining whether or not to show training
%           results on single image
%           resize is bool determining whether or not to scale to 768 by
%           768
%EFFECTS: Returns model - struct consisting of weighted feature classifier
%           model using adaboost

dataset = [];
all_classes = [];
%parse filenames, build dataset
for i = 1:size(filenames,1)
    I = imread(filenames{i,1});
    Icolored = imread(filenames{i,2}); 
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
    
if test 
    %look at first image in filenames array
    I=imread(filenames{1,1});
    if length(size(I))==3
       I=rgb2gray(I);
    end

    I = crop_footer(I);
    
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

