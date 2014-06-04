function img = run_snake(pid,eye,time)
%Add the location of the XML file with patient information
addpath('..');
    
%Add the location of the images
addpath(genpath('../Test Set'));


%Get the path and load the image
the_path = get_pathv2(pid,eye,time,'original');
img = imread(the_path);
img = im2double(img);

figure, imshow(img);
[ycoord, xcoord] = ginput(8);

P = zeros(length(ycoord), 2);
pindex = 1;
for i=1:length(ycoord)
    P(pindex, 1) = xcoord(i);
    P(pindex, 2) = ycoord(i);
    pindex = pindex + 1;
end

Options=struct;
Options.Verbose=true;
Options.Iterations=100;
Options.Wedge=3;

[~,J] = Snake2D(img, P, Options);


yesnobutton = questdlg('Does this snaking look good?...Bwhahahaha!', the_path,'Yes','No', 'Cancel', 'Cancel');
switch yesnobutton
    case 'Yes'
        [~,name,~] = fileparts(the_path);
        imwrite(J, [name, '.jpg'], 'jpg');
    case 'No'

    case 'Cancel'
        return;
end

end