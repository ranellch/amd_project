%  [labels strengths] = growcut(img, labels)
%
%  GrowCut algorithm
%  from "GrowCut" - Interactive Multi-Label N-D Image Segmentation
%       By Cellular Autonoma
%  by Vladimir Vezhnevets and Vadim Konouchine
%
%  usage: [labels, strengths] = growcutmex(image, labels)
%         image can be RGB or grayscale
%         labels has values: -1 (bg), 1 (fg), or 0 (undef.)
% 
%         resulting labels will be either 0 (bg) or 1 (fg)
%         resulting strengths will be between 0 and 1
%
%  coded by: Shawn Lankton (www.shawnlankton.com)



function [l s] = growcut(img, labels)
  
  img = double(img);
  si = size(img);
  sl = size(labels);
  assert(numel(unique(labels))==3,...
         'labels must be comprised of -1, 0, 1');
  assert(all(sl(1:2)==si(1:2)),...
         'labels and image must be the same size');
  
  [l s] = growcutmex(img,labels);
  
