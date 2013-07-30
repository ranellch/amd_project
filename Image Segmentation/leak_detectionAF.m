function [ BWleak ] = leak_detectionAF( varargin )
%BWleak = leak_detection(I, [Diskmin Diskmax])
%Takes in grayscaled AF image as input I and returns binary image BWleak consisting solely of
%the leak being extracted. Uses morphological techniques to eliminate
%vessels, optic disks, and other unwanted objects before segmenting out
%area of leakage.  
%Diskmin and Diskmax are optional variables specifying an approximate pixel
%range for the radius of the optic disk


I = varargin{1};
if nargin == 2;
    Diskmin = min(varargin{2});
    Diskmax = max(varargin{2});
else
    Diskmin = 100;
    Diskmax = 200;
end

%Get rid of vessels
se=strel('disk',20);
Iclose=imclose(I,se);


%Find optic disc, if present
%split findcircles algorithm into 4 iterations to improve speed
step = (Diskmax - Diskmin)/4;
centerStrongest = [];
radiusStrongest = [];
maxMetric = 0;
for i = 1:4
    [centers,radii,metrics] = imfindcircles(Iclose,[Diskmin + step*(i-1), Diskmin + step*i],'sensitivity', .96);
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
        [xgrd, ygrd] = meshgrid(1:size(Iclose,2), 1:size(Iclose,1));   
        x = xgrd - centerStrongest(1);  
        y = ygrd - centerStrongest(2);
        omask = x.^2 + y.^2 < r^2;  
        Inodsc = Iclose;
        Inodsc(omask) = 255;
else
    Inodsc = Iclose;
end
clear Iclose
figure, imshow(Inodsc)

% tophat filter to get rid of background
se1 = strel('line',size(I,2)/2,0);
Ibot=imbothat(Inodsc,se1);
clear Inodsc
figure, imshow(Ibot)

%get seed points for leak reconstruction
Imarker = Ibot == max(Ibot(:));
if numel(Imarker~=0) > 1
    %eliminate duplicate connected seed locations to improve reconstruction
    %speed
    Imarker = bwmorph(Imarker, 'shrink', Inf);
end

%apply threshold to get mask for leak reconstruction
thresh = graythresh(Ibot)*255;
Imask = Ibot >= thresh;
Irecon = imreconstruct(Imarker,Imask); %only reconstruct area with seed points (max intensity)
clear Itop
clear Imarker
clear Imask

%apply second threshold to further refine leak mask
Ileak = uint8(Irecon).*I;
thresh = graythresh(Ileak(Ileak~=0))*255;
BWleak = Ileak >= thresh;

%clean up final leak mask
BWleak = imfill(BWleak, 'holes');
BWleak = bwmorph(BWleak,'majority');

%only keep biggest connected region
CC = bwconncomp(BWleak);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,idx] = max(numPixels);
BWleak = zeros(size(BWleak));
BWleak(CC.PixelIdxList{idx}) = 1;

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





