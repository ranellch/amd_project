function runtest(directory)

xDoc= xmlread('reg_images.xml');
images = xDoc.getElementsByTagName('image');
results = cell(1000,4);
results{1,1}='Trial';
results{1,2}='% change hypr';
results{1,3}='% change hypo';
results{1,4}='MAQ';
index = 2;
list=dir(directory);
    list = setdiff({list.name},{'.','..','.DS_Store'});
    
    for i=1:length(list)
        
        if isdir(list{i})
            id=list{i};
            path = strcat('./Reg Set/',list{i},'/');
            sublist = dir(path);
            pics = setdiff({sublist.name},{'.','..','.DS_Store'});
              for j=1:length(pics)
                  file = pics{j};
                  ind=strfind(file,'_corrimg');% look for correlated images
                    if isempty(ind)
                        continue
                    else                    
                         %get correlated image tags
                         for count = 1:images.getLength  
                            cimage = images.item(count - 1);
                            corrpath = char(cimage.getAttribute('path'));
                            if strcmpi(corrpath, file)                               
                                visit2 =  char(cimage.getAttribute('path'));
                                time2 = char(cimage.getAttribute('time'));
                                break
                            end
                         end
                         %get base image tags
                         [~, ~, ext] = fileparts(file);
                         bfile=strcat(file(1:ind-1),'_baseimg', ext);
                         for count = 1:images.getLength
                             bimage = images.item(count-1);
                             basepath = char(bimage.getAttribute('path'));
                             if strcmpi(basepath, bfile)                               
                                visit1 = char(bimage.getAttribute('path'));
                                time1 = char(bimage.getAttribute('time'));
                                break
                             end
                         end
                            trialname = strcat('-', time1, 'v', time2);
                            data = compare_maculas_best('AF',visit1, visit2, id, trialname);
                            data=struct2cell(data)';
                            results(index) = data;
                            index = index+1;
                    end
              end
        end 
    end

xlwrite('results.xls',results); 

end
        
