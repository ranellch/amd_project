function [ density_map ] = plot_vdensity( vessels )

 vessels = double(vessels);
 density_map = imfilter(vessels, ones(100)/(100*100), 'symmetric');
 figure, imagesc(density_map)


end

