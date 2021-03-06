function [ g ] = splitmerge(f, mindim , fun)
%*******ADAPTED FROM GONZALEZ, WOODS "DIGITAL IMAGE PROCESSING IN MATLAB"
% FIFTH EDITION, 2009 - FUNCTION SPLITMERGE ON PG 428***********
%
% G = SPLITMERGE(F, MINDIM, @PREDICATE) segments image F using
% split=and-merge based on quad tree decomposition.  MINDIM (positive
% integer power of 2) specifies the minimum allowed dimension of the quadtree
% regions.  If necessary, the function pads the image with zeros to the
% nearest square size that is an integer power of 2.  The result is cropped
% back to the original size of the input image.  
%
% PREDICATE is a function in the MATLAB path provided by the user.  Its
% syntax is FLAG = PREDICATE(REGION)



%Pad image with zeros to guarantee that function qtdecomp will split
%regions down to size 1-by-1.
Q = 2^nextpow2(max(size(f)));
[M, N] = size(f);
f = padarray(f, [Q-M, Q-N], 'post');

%Perform splitting
S= qtdecomp(f, @split_test, mindim, fun);

%Now Merge by looking at each quadregion and setting all its elements to 1 if
%the block satisfies the predicate.
Lmax =  full(max(S(:)));
g = zeros(size(f));
for K = 1:Lmax
    [vals, r, c] = qtgetblk(f, S, K);
    if ~isempty(vals)
        %Check the predicate for each of the regions of size K-by-K with
        %coordinates given by vectors r and c.
        for i = 1:length(r)
            xlow = r(i); ylow = c(i);
            xhigh = xlow + K - 1; yhigh = ylow + K - 1;
            region = f(xlow:xhigh, ylow:yhigh);
            flag = feval(fun, region);
            if flag
                g(xlow:xhigh, ylow:yhigh)  = 1;
            end
        end
    end
end

%Crop and exit
g = g(1:M, 1:N);
g=logical(g);
end

%------------------------------------------------------------------------
function v = split_test(B, mindim, fun)
    %Determines whether quadregions are split.  Returns in v logical 1s for
    %the blocks that should be split and logical 0s for those that should
    %not.
    
    k = size(B,3); %number of regions in B at this step
    
    v(1:k) = false;
    for i = 1:k
        quadregion = B(:,:,i);
        if size(quadregion, 1) <= mindim || any(quadregion(:)) == false;
            v(i) = false;
            continue
        end
        flag = feval(fun, quadregion);
        if ~flag || size(quadregion, 1) >= 64 
            v(i) = true;
        end
    end
end


