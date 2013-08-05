function [ BWhyper, Irgb ] = machyper_detect( varargin )
%[BWleak, Irgb] = hypo_detection(I)
% Analyzes grayscale AF image of the macula I and returns binary image BWhypo consisting
%solely of any hyperfluoresence present in the macula along with Irgb showing hyperfluorescence tinted red. 
%Uses morphological techniques to eliminate vessels before segmenting out area of hyperfluorescence.  

Iorg = varargin{1};
if nargin == 2
    BWhypo = varargin{2};
end
I=imadjust(Iorg);

%close to get rid of vessels
se=strel('disk',round(size(I,1)/50));
Iclose = imclose(I,se);

%  figure, imshow(Iclose)

se=strel('disk',round(size(I,1)/10));
Itop = imtophat(Iclose,se);


% figure, imshow(Itop)

%apply multiple thresholds to further refine hypo mask using original
%image.  keep thresholding until normalized between class variance (difference between class means) changes
%by less than .5 on next iteration
thresh1 = graythresh(Itop)*255;
object1 = Itop(Itop >= thresh1);
background1 = Itop(Itop < thresh1);
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

BWhyper = Itop>thresh1;
clear Itop

%clean up final hypo mask
BWhyper = bwmorph(BWhyper,'majority');

% %clean up regions with less than 100 pixels 
CC = bwconncomp(BWhyper);
numPixels = cellfun(@numel,CC.PixelIdxList);
for idx = 1:length(numPixels)
    if numPixels(idx) < 100 
        BWhyper(CC.PixelIdxList{idx}) = 0;
    end
end
BWhyper = logical(BWhyper);

% clean up regions on border (probably gradients)
BWhyper = imclearborder(BWhyper);

% % clean up regions with mean intensity less than 0.5 std deviation away from
% % mean of background
% if nargin == 2
%     hyper = mean(Iorg(~BWhypo&~BWhyper))+0.5*std(double(Iorg(~BWhypo&~BWhyper)));  
%     for idx = 1:length(CC.PixelIdxList)
%         pixels = CC.PixelIdxList{idx};
%         if mean(Iorg(pixels)) <= hyper
%             BWhyper(CC.PixelIdxList{idx}) = 0;
%         end
%     end
% end
    
BWhyper = logical(BWhyper);

%show tinted hypo region
[Iind,map] = gray2ind(Iorg,256);
Irgb=ind2rgb(Iind,map);
Ihsv = rgb2hsv(Irgb);
hueImage = Ihsv(:,:,1);
hueImage(BWhyper>0) = 0.011; %red
Ihsv(:,:,1) = hueImage;
satImage = Ihsv(:,:,2);
satImage(BWhyper>0) = .8; %semi transparent
Ihsv(:,:,2) = satImage;
Irgb = hsv2rgb(Ihsv);

% figure, imshow(Irgb)

end





