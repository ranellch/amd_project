function iterate_over_img()
    fid = fopen('include.dataset');
    paths = textscan(fid,'%q %d %*[^\n]');
    fclose(fid);
    
    for x=1:size(paths{1}, 1)
        pid = char(paths{1}(x));
        time = num2str(paths{2}(x));
        
        disp([pid, ' - ', time, ': ']);
        find_optic_disc(pid,time,0);
    end
end