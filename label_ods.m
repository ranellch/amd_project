function label_ods(fname)
addpath(genpath('./Test Set/'))

fid = fopen(fname, 'r');
images = textscan(fid,'%q %q %d %*[^\n]');
fclose(fid);

for i = 1:size(images{1},1)
    pid = char(images{1}{i});
    eye = char(images{2}{i});
    time = num2str(images{3}(i));
    iname = ['.\Test Set\Labeled\AMD ODs\',pid,'_',eye,'_',time,'_od.tif'];
    I = imread(get_pathv2(pid,eye,time,'original'));
    if size(I,3) > 1
        I=rgb2gray(I);
    end
    figure(1), imshow(I)
    Obj = imfreehand();
    xy = round(Obj.getPosition);
    delete(Obj);
    xy(xy(:,1)< 1,1) = 1;
    xy(xy(:,1)>size(I,2),1) = size(I,2);
    [~,BW] = roifill(I,xy(:,1),xy(:,2));
    imwrite(BW,iname,'tiff');
    update_xml(pid,eye,time,'optic_disc',iname(12:end));
end

