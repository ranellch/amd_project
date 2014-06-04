function analyze_od()
%Get the images to include from this list
fid = fopen('od_draw_test.dataset', 'r');
includes = textscan(fid,'%q %q %d %*[^\n]');
fclose(fid);

pid = 'none';
eye = 'none';
time = -1;
for x=1:size(includes{1}, 1)
    pid = char(includes{1}{x});
    eye = char(includes{2}{x});
    time = num2str(includes{3}(x));  
    
end
end