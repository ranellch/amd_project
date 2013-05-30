function correspEdgeDisplay(matches, ttype, im1, im2)
%correspEdgeDisplay displays image match under affine flow
%   correspEdgeDisplay(MATCHES, TTYPE, IM1, IM2) takes MATCHES, a structure
%   returned by correlCorresp, TTYPE, a transform type for CP2TFORM, and
%   the two images that were used to estimate the matches. A transform of
%   the type specified is fitted to the match vectors and used to warp IM1.
%   The edges from the images are displayed in the current figure, using
%   the following colours:
%
%       green: edges from IM1
%       blue: edges from IM2
%       red: edges from IM1 after warping
%
%   Good results are indicated if the red edges are close to the blue
%   edges.
%
%   See also: correCorresp, correspDemo, cp2tform

% Copyright David Young 2010

% Get the transform
tform = cp2tform((matches([1 2],:))', (matches([3 4],:))', ttype);
% Apply the transform to image 1
im1trans = imtransform_same(im1, tform);

e1 = edge(im1, 'canny');
e1trans = edge(im1trans, 'canny');
e2 = edge(im2, 'canny');

% combine the edges to show them in different colours
edges(:,:,1) = 1 - (e1 | e2);
edges(:,:,2) = 1 - (e2 | e1trans);
edges(:,:,3) = 1 - (e1 | e1trans);

imshow(edges);

end

