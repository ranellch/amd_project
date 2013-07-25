function [ g ] = splitmerge(f, mindim, fun )
%*******ADAPTED FROM GONZALEZ, WOODS "DIGITAL IMAGE PROCESSING IN MATLAB"
% FIFTH EDITION, 2009 - FUNCTION SPLITMERGE ON PG 428***********
%
% G = SPLITMERGE(F, MINDIM, @PREDICATE) segments image F using
% split=and-merge based on quad tree decomposition.  MINDIM (positive
% integer power of 2) specifies the minimum allowed dimension of the quadtree
% regions.  If necessary, the function pads the image with zeros to the
% nearest square size that is an integer power of 2.  The result is cropped
% back to the original size of the input image.  In the output, G, each
% connected region is labeled with a different integer.
%
% PREDICATE is a function in the MATLAB path provided by the user.  Its
% syntax is FLAG = PREDICATE(REGION)


end

