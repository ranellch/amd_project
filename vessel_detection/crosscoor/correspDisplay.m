function correspDisplay(corresps, im, col)
%correspDisplay Display image correspondences
%   correspDisplay(CORRESPS, IM) takes CORRESPS, a set of matches as
%   returned by correlCorresp, and an image IM. Vectors are drawn on the
%   image representing the motion of the features. The point at which the
%   feature is initially located is marked with a circle and a motion
%   vector is shown as a line pointing away from the circle.
%
%   correspDisplay(CORRESPS, REGION) where REGION is a row vector, draws
%   the vectors in the current figure without setting a background. REGION
%   can have 4 elements and specifies the region in which to draw vectors
%   in the format [Ymin Ymax Xmin Xmax]. REGION may have 2 elements giving
%   [Ymax Xmax]; Ymin and Xmin both default to 1. Thus correspDisplay(FLOW,
%   SIZE(IM)) displays the flow for an image on a blank canvas.
%
%   correspDisplay(..., COL) sets the colour in which to draw the vectors.
%   COL must be a single colour character, as for PLOT.
%
%   See also: correlCorresp, correspDemo

% Copyright David Young 2010

if isequal(size(im), [1 2])
    im = [1 im(1) 1 im(2)];
end
if isequal(size(im), [1 4])
    axis(im([3 4 1 2]));
    axis equal;
    set(gca,'YDir','reverse');
else
    imshow(im, []);
end
    
if nargin < 3
    col = 'g';
end

hold on;
disp_vecs(corresps, col);
hold off;

end

%-----------------------------------------------------------------------

function disp_vecs(corresps, colour)
% Display the flow field as a set of vectors on a rectangular grid

xs1 = corresps(1,:);
ys1 = corresps(2,:);
xs2 = corresps(3,:);
ys2 = corresps(4,:);

plot(xs1, ys1, [colour 'o']);
plot([xs1; xs2], [ys1; ys2], [colour '-']);

end
