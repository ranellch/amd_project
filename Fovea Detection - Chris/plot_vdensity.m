function [ density_map ] = plot_vdensity( vessels )

 vessels = double(vessels);
 density_map = imfilter(vessels, ones(150)/(150*150), 'symmetric');

end

