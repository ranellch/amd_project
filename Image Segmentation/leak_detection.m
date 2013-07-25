function [ BWleak ] = leak_detection( varargin )
%BWleak = leak_detection(I, [Diskmin Diskmax])
%Takes in grayscaled FA image as input I and returns binary image BWleak consisting solely of
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
Iopen=imopen(I,se);
figure, imshow(Iopen)


%Find optic disk, if present
[centers1,radii1,metric1] = imfindcircles(Iopen,[Diskmin, Diskmin + (Diskmax-Diskmin)/2],'sensitivity', .95);
[centers2,radii2,metric2] = imfindcircles(Iopen,[Diskmin + (Diskmax-Diskmin)/2, Diskmax],'sensitivity', .95);

if ~isempty(centers1) || ~isempty(centers2)
    if ~isempty(centers1) && ~isempty(centers2)
    %only look at most likely circle 
        switch metric1(1) >= metric2(1)
            case 1 
                centerStrongest = centers1(1,:);
                radiusStrongest = radii1(1);
            case 0
                centerStrongest = centers2(1,:);
                radiusStrongest = radii2(1);
        end
    elseif ~isempty(centers1)
        centerStrongest = centers1(1,:);
        radiusStrongest = radii1(1);
    elseif ~isempty(centers2)
        centerStrongest = centers2(1,:);
        radiusStrongest = radii2(1,:);
    end
        %mask optic disk 
        leeway = .6;
        r = radiusStrongest*(1+leeway);
        [xgrd, ygrd] = meshgrid(1:size(Iopen,2), 1:size(Iopen,1));   
        x = xgrd - centerStrongest(1);  
        y = ygrd - centerStrongest(2);
        omask = x.^2 + y.^2 >= r^2;  
        Inodsk = Iopen.*uint8(omask);
        figure, imshow(Inodsk);
else
    Inodsk = Iopen;
end

% tophat filter to get rid of background
se1 = strel('line',300,0);
se2 = strel('line',300,90);
Itop=imtophat(Inodsk,se1);
Itop=imtophat(Itop,se2);
figure, imshow(Itop)



% quad tree decomp that bitch

end





