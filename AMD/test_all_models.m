testname = 'Control Images - Hypofluorescence';
itt = 30;

%Open the file to determine which images to use for training 
 fid = fopen(filename_input, 'r');
 IDs = textscan(fid,'%q %d %q %*[^\n]');
 fclose(fid);
        
        numimages = size(IDs{1}, 1);

%Parse XML document 
xDoc= xmlread('images.xml');
images = xDoc.getElementsByTagName('image');

for i = 1:numimages
   
    tester=allimages(i,:);
    modelname=tester{1}; %name each model after image that will be tested

    %Start map object
    mapObj = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
    
    %Java lists to keep track of original filename and vessel detection
    the_list_path = java.util.LinkedList;
    the_list_transform = java.util.LinkedList;
    total_count = 0;
      
	%Loop on the image field in the images tag
    for count=1:images.getLength
        image = images.item(count - 1);

        %Get the attribute from the image tag
        id = char(image.getAttribute('id'));
        
        if strcmp(id, image_string) == 1       
            the_path = char(image.getAttribute('path'));
            the_time = char(image.getAttribute('time'));
            transform = 'none';
            
            %Get a map list of the images to compare
            mapObj(str2num(the_time)) = total_count;
            
            %If transform tag exists then get it else keep as null
            try
                transform = char(image.getAttribute('transform'));
            catch 
                transform = 'none';
            end
            the_list_transform.add(transform);
                    
            %Get the path name for this badboy
            the_list_path.add(the_path);
            
            %Increment the index of the 
            total_count = total_count + 1;
        end
    end
    rowindex=ones(numimages,1);
    rowindex(i)=0;
    trainers = allimages(rowindex~=0,:);
    
    disp('New model with images:')
    disp(trainers(:,1))
    model = train_adaboost( modelname, testname, trainers, itt, 0, 1 );
    test_classifier( tester, model, testname, i-1, 1 );

    disp(['Trial ', int2str(i), ' complete'])	
    disp('=====================================================')	

end

