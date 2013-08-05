function [ BWhypo, Irgb ] = machypo_detect( varargin )
%[BWleak, Irgb] = hypo_detection(I)
%Analyzes grayscale AF image of the macula I and returns binary image BWhypo consisting
%solely of any hypofluoresence present in the macula along with figure Irgb showing hypo region tinted red. 
%Uses morphological techniques to eliminate vessels before segmenting out area of hypofluorescence.  

Iorg = varargin{1};

I=imcomplement(Iorg);


%Get rid of vessels
se=strel('disk',round(size(I,1)/100));
Iopen=imopen(I,se);

% figure, imshow(Iopen)

%apply threshold using Otsu's method 
thresh = graythresh(Iopen)*255;
BWthresh1 = Iopen >= thresh;
clear Iopen

%only keep biggest connected region 
CC = bwconncomp(BWthresh1);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
BWthresh1 = zeros(size(BWthresh1));
BWthresh1(CC.PixelIdxList{idx}) = 1;
BWthresh1 = logical(BWthresh1);

Ithresh1 = I .* uint8(BWthresh1);
% figure, imshow(Ithresh1)

%apply multiple thresholds to further refine hypo mask using original
%image.  keep thresholding until normalized between class variance (difference between class means) changes
%by less than .01 on next iteration
thresh1 = graythresh(Ithresh1(BWthresh1))*255;
object1 = Ithresh1(Ithresh1 >= thresh1);
background1 = Ithresh1(Ithresh1 < thresh1);
muO1 = mean2(object1);
muB1 = mean2(background1);
var1 = ((muB1-muO1)^2)/255^2;

thresh2 = graythresh(object1)*255;
object2 = object1(object1 >= thresh2);
background2 = object1(object1 < thresh2);
muO2 = mean2(object2);
muB2 = mean2(background2);
var2 = ((muB2-muO2)^2)/255^2;

while abs(var2 - var1) >= .01
    
    thresh1 = thresh2;
    object1 = object2;
    var1 = var2;
    
    thresh2 = graythresh(object1)*255;
    object2 = object1(object1 >= thresh2);
    background2 = object1(object1 < thresh2);
    muO2 = mean2(object2);
    muB2 = mean2(background2);
    var2 = (muB2-muO2)^2/255^2;
end

BWhypo = Ithresh1>thresh1;
clear Ithresh1

%clean up final hypo mask
BWhypo = imfill(BWhypo, 'holes');
BWhypo = bwmorph(BWhypo,'majority');

% %clean up regions with less than 200 pixels
CC = bwconncomp(BWhypo);
numPixels = cellfun(@numel,CC.PixelIdxList);
for idx = 1:length(numPixels)
    if numPixels(idx) < 200
        BWhypo(CC.PixelIdxList{idx}) = 0;
    end
end
BWhypo = logical(BWhypo);

%make sure it isn't a false positive


%show tinted hypo region
[Iind,map] = gray2ind(Iorg,256);
Irgb=ind2rgb(Iind,map);
Ihsv = rgb2hsv(Irgb);
hueImage = Ihsv(:,:,1);
hueImage(BWhypo>0) = 0.011; %red
Ihsv(:,:,1) = hueImage;
satImage = Ihsv(:,:,2);
satImage(BWhypo>0) = .8; %semi transparent
Ihsv(:,:,2) = satImage;
Irgb = hsv2rgb(Ihsv);

% figure, imshow(Irgb)

end





