function [feat1, feat2] = align_vlfeat(img1, img2)
    %Add vlfeat to the pathbox
    run('vlfeat/toolbox/vl_setup');
    
    %Find the sift image features
    [f1,d1] = vl_sift(img1);
    [f2,d2] = vl_sift(img2);
        
    %Try to find the mathces between these two images
    [matches, scores] = vl_ubcmatch(d1, d2);
    
    feat1 = f1(1:2, matches(1,:));
    feat2 = f2(1:2, matches(2,:));
end