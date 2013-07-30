function [ BWhypo ] = hypo_detection( varargin )
%BWleak = leak_detection(I, [Diskmin Diskmax], tolerance)
%Analyzes grayscale AF image I and returns binary image BWhypo consisting
%solely of any hypofluoresence present in the macula. Uses morphological techniques to eliminate
%vessels, optic discs, and other unwanted objects before segmenting out
%area of leakage.  
%Diskmin and Diskmax are optional variables specifying an approximate pixel
%range for the radius of the optic disk
%Tolerance is an optional variable in the range [0 1] that determines
%threshold deviation (higher tolerance = lower threshold)

Iorg = varargin{1};
figure, imshow(Iorg)

I=imcomplement(Iorg);
I=imadjust(I);

if nargin >= 2 
    if numel(varargin{2}) == 2
         Diskmin = min(varargin{2});
         Diskmax = max(varargin{2});
    elseif numel(varargin{2}) == 1
         Diskmin = 100;
         Diskmax = 200;
        tolerance = varargin{2};
    elseif nargin == 3
        tolerance = varargin{3};
    end
else
    Diskmin = 100;
    Diskmax = 200;
    tolerance = 0;
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
    [centers,radii,metrics] = imfindcircles(Iopen,[Diskmin + step*(i-1), Diskmin + step*i],'sensitivity', .99);
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
    Inodsc = Iopen;
    omask = zeros(size(Iopen));
end
figure, imshow(Inodsc)


%apply threshold using Otsu's method 
thresh = graythresh(Iopen(~omask))*255;
clear Iopen
thresh = thresh * (1-tolerance);
BWthresh1 = Inodsc >= thresh;

%throw out regions on image border
BWthresh1 = imclearborder(BWthresh1, 4);

%dilate regions left
BWthresh1 = bwmorph(BWthresh1, 'dilate',1);

%only keep biggest connected region 
CC = bwconncomp(BWthresh1);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
BWthresh1 = zeros(size(BWthresh1));
BWthresh1(CC.PixelIdxList{idx}) = 1;

Ithresh1 = I .* uint8(BWthresh1);
figure, imshow(Ithresh1)

%apply second threshold to further refine leak mask using original
%image 
thresh = graythresh(Ithresh1(Ithresh1>0))*255;
thresh = thresh * (1-tolerance);
BWhypo = Ithresh1 >= thresh;

%clean up final leak mask
BWhypo = imfill(BWhypo, 'holes');
BWhypo = bwmorph(BWhypo,'majority');
BWhypo = bwmorph(BWhypo, 'clean');
BWhypo = logical(BWhypo);

%make sure it isnt a false positive
if mean2(Iorg(BWhypo)) > 100
    BWhypo = zeros(size(Iorg));
end

%show tinted leak
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





