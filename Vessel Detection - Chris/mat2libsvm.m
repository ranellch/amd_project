function mat2libsvm(filename_out)
    %specify output filename as argument

   addpath('..\libsvm-3.18\matlab');
   
   filename_gabor = 'vessel_gabor.mat';
   gabor_file = matfile(filename_gabor);
   variable_data_gabor =  gabor_file.dataset;
        
   filename_lineop = 'vessel_lineop.mat';
   lineop_file = matfile(filename_lineop);
   variable_data_lineop =  lineop_file.dataset;
   
   categories = lineop_file.classes;
   combined_matrices = [variable_data_gabor, variable_data_lineop];
   
   libsvmwrite(filename_out, categories, sparse(combined_matrices));
end
