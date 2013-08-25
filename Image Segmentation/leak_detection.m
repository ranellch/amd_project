function [ BWleak ] = leak_detection( varargin )
%BWleak = leak_detection(I, [Diskmin Diskmax], tolerance)
%Takes in grayscaled FA image as input I and returns binary image BWleak consisting solely of
%the leak being extracted. Uses morphological techniques to eliminate
%vessels, optic disks, and other unwanted objects before segmenting out
%area of leakage.  
%Diskmin and Diskmax are optional variables specifying an approximate pixel
%range for the radius of the optic disk
%Tolerance is an optional variable in the range [0 1] that determines
%threshold deviation (higher tolerance = lower threshold)

I = varargin{1};
figure, imshow(I)

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
    [centers,radii,metrics] = imfindcircles(Iopen,[Diskmin + step*(i-1), Diskmin + step*i],'sensitivity', .97);
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

%throw out regions on image border
% BWthresh1 = imclearborder(BWthresh1, 4);

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

%apply multiple thresholds to further refine leak mask using original
%image.  keep thresholding until normalized variance (difference between class means)changes
%by less than .1 on next iternation
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

while abs(var2 - var1) >= .1
    
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

BWleak = Ithresh1>thresh1;
clear Ithresh1

%clean up final leak mask
BWleak = imfill(BWleak, 'holes');
BWleak = bwmorph(BWleak,'majority');

% %clean up regions with less than 100 pixels
CC = bwconncomp(BWleak);
numPixels = cellfun(@numel,CC.PixelIdxList);
for idx = 1:length(numPixels)
    if numPixels(idx) < 100
        BWleak(CC.PixelIdxList{idx}) = 0;
    end
end
BWleak = logical(BWleak);

%show tinted leak
[Iind,map] = gray2ind(I,256);
Irgb=ind2rgb(Iind,map);
Ihsv = rgb2hsv(Irgb);
hueImage = Ihsv(:,:,1);
hueImage(BWleak>0) = 0.011; %red
Ihsv(:,:,1) = hueImage;
satImage = Ihsv(:,:,2);
satImage(BWleak>0) = .8; %semi transparent
Ihsv(:,:,2) = satImage;
Irgb = hsv2rgb(Ihsv);

figure, imshow(Irgb)

end





