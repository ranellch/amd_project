function array = matstack2array(matstack) 
%Reshapes a 3D image into a numpixels x length(featurevector) array. 
%Featurevectors are arranged as a list of pixels organized in the same way as if you use the colon operator
%on a 2D image (I(:))

array = zeros(size(matstack,1)*size(matstack,2),size(matstack,3));
count = 1;
for x = 1:size(matstack,2)
    for y = 1:size(matstack,1)
        array(count,:) = matstack(y,x,:);
        count = count + 1;
    end
end

