function [ BWhypo ] = hypo_detection( varargin )
%BWleak = hypo_detection(I, [Diskmin Diskmax])
%Analyzes grayscale AF image I and returns binary image BWhypo consisting
%solely of any hypofluoresence present in the macula. Uses morphological techniques to eliminate
%vessels, optic discs, and other unwanted objects before segmenting out
%area of leakage.  
%Diskmin and Diskmax are optional variables specifying an approximate pixel
%range for the radius of the optic disk


Iorg = varargin{1};
figure, imshow(Iorg)

I=imcomplement(Iorg);

if nargin == 2 
    Diskmin = min(varargin{2});
    Diskmax = max(varargin{2});
else
    Diskmin = 100;
    Diskmax = 200;
end


%Get rid of vessels
se=strel('disk',round(size(I,1)/100));
Iopen=imopen(I,se);


%Find optic disc, if present
%split findcircles algorithm into 4 iterations to improve speed
step = (Diskmax - Diskmin)/4;
centerStrongest = [];
radiusStrongest = [];
maxMetric = 0;
for i = 1:4
    [centers,radii,metrics] = imfindcircles(Iopen,[Diskmin + step*(i-1), Diskmin + step*i],'sensitivity', .9);
    if isempty(metrics)
        continue
    end
    if  metrics(1) > maxMetric
        maxMetric = metrics(1);
        centerStrongest = centers(1,:);
        radiusStrongest = radii(1);
    end
end


if ~isempty(centerStrongest)
        %mask optic disc 
        leeway = 1;
        r = radiusStrongest*(1+leeway);
        [xgrd, ygrd] = meshgrid(1:size(Iopen,2), 1:size(Iopen,1));   
        x = xgrd - centerStrongest(1);  
        y = ygrd - centerStrongest(2);
        omask = x.^2 + y.^2 >= r^2;  
        Inodsc = Iopen.*uint8(omask);
else
        omask = logical(ones(size(Iopen)));
        Inodsc = Iopen.*uint8(omask);
end
figure, imshow(Inodsc)
clear Iopen

%apply threshold using Otsu's method 
thresh = graythresh(Inodsc(omask))*255;
BWthresh1 = Inodsc >= thresh;
figure, imshow(BWthresh1)

%throw out regions on image border
BWthresh1 = imclearborder(BWthresh1, 4);

%dilate regions left
BWthresh1 = bwmorph(BWthresh1, 'dilate',5);

%only keep biggest connected region 
CC = bwconncomp(BWthresh1);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
BWthresh1 = zeros(size(BWthresh1));
BWthresh1(CC.PixelIdxList{idx}) = 1;
BWthresh1 = logical(BWthresh1);

Ithresh1 = I .* uint8(BWthresh1);
figure, imshow(Ithresh1)
clear Inodsc

%apply multiple thresholds to further refine hypo mask using original
%image.  keep thresholding until normalized between class variance (difference between class means) changes
%by less than .5 on next iteration
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

while abs(var2 - var1) >= .5
    
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

BWhypo = I.*uint8(Ithresh1>thresh1);
clear Ithresh1

%clean up final hypo mask
BWhypo = imfill(BWhypo, 'holes');
BWhypo = bwmorph(BWhypo,'majority');

% %clean up regions with less than 100 pixels
CC = bwconncomp(BWhypo);
numPixels = cellfun(@numel,CC.PixelIdxList);
for idx = 1:length(numPixels)
    if numPixels(idx) < 100
        BWhypo(CC.PixelIdxList{idx}) = 0;
    end
end
BWhypo = logical(BWhypo);

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

figure, imshow(Irgb)

end





