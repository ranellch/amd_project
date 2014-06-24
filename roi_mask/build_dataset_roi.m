function build_dataset_roi()
    run('../vlfeat/toolbox/vl_setup');
    
    %Constants for file names
    roi_file = 'roi_classify.mat';

    %Get the time of the start of this function to get how long it took to run.
    t = cputime;

    %Remove texture file if already exists
    if(exist(roi_file, 'file') == 2)
        delete(roi_file);
    end
    file_obj = matfile(roi_file,'Writable',true);
    file_obj.dataset = [];
    file_obj.classes = [];

    img = imread('SymphonyWeb32650_12.TIF');
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    
    mask = imread('SymphonyWeb32650_12_roi.jpeg');
    if(size(mask,3) > 1)
        mask = rgb2gray(mask);
    end
    mask = im2bw(mask);
    
    [lbpout, label_vector] = image_lbp(img, mask);
    
    file_obj.dataset = lbpout;
    file_obj.classes = label_vector;
    
    %Display the time required to run this
    e = cputime - t;
    disp(['ROI Build Classifier Time (min): ', num2str(e/60.0)]);
end

function [array] = matstack2array(inarr)
    array = zeros(size(inarr,1)*size(inarr,2),size(inarr,3));
    count = 1;
    for x = 1:size(inarr,2)
        for y = 1:size(inarr,1)
            array(count,:) = inarr(y,x,:);
            count = count + 1;
        end
    end
end
