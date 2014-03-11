
[~,filenames,~] = xlsread('hypo image list.xlsx');
count=6;
for i=count+1:length(filenames)
    I1=imread(filenames{i,1});
    [I1,rect]=imcrop(I1);
    imwrite(I1,['./Test Images/Hypofluorescence/Cropped Originals/hypo ',int2str(count), '.tiff'],'tiff');
    I2=imread(filenames{i,2});
    if size(I2,3)>3
        I2=I2(:,:,1:3);
    end
    imwrite(imcrop(I2,rect),['./Test Images/Hypofluorescence/Cropped Colored/hypo ',int2str(count), ' colored.tiff'],'tiff');
    xlwrite('hypo image list.xlsx',{['hypo ',int2str(count), '.tiff']},['C',int2str(i),':','C',int2str(i)]);
    xlwrite('hypo image list.xlsx',{['hypo ',int2str(count), ' colored.tiff']},['D',int2str(i),':','D',int2str(i)]);
    count=count+1;
end
