function [x,y,shift] = find_optic_disc(image, time, debug)
addpath('..');
addpath('../Test Set');

%Get the path name for the image and time
filename = get_path(image, time);
img = imread(filename);
if(size(img,3) ~= 1)
    img=rgb2gary(img);
end

%From the filename get the snaked image
snaked_img = get_snaked_img(filename);

%Calculate the mean shift
t=cputime;
shift=mean_shift_segment(img);
e = cputime-t;
disp(['Mean Shift (sec): ', num2str(e)]);

x=-1;
y=-1;

%iterate over each segement
iterate_segments(img, snaked_img, shift, debug);

end