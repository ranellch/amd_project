function init_config(data_set_name)
% clear global config;
global config debug

config = struct();

%% select data set to run on.
if(nargin > 0)
    config.data_set_name = data_set_name;
else
    config.data_set_name = 'ten_concentric_circles';
%     config.data_set_name = 'olympic_circles';
end
%% select sigma list
switch(config.data_set_name)
    case 'olympic_circles'
        % Olympic Circles
        config.sigma_list = [0.025 0.05 0.1 0.3 0.5 0.75 1 1.5 2 3 5];
    case 'ten_concentric_circles'
        % Concentric Circles
        config.sigma_list = [0.1 0.3 0.5 0.75 1 2 3 5 7 10 15 20 25 30];
    otherwise
        error('invalid data set name');
end


%% parameters specific to kernel learning

config.gamma = 100; % default value of gamma for skms 
config.useLowRank = true;
config.thresh = 0.01;
config.max_iters = 100000;

%% setup debug/visualization configuration
debug = struct();
debug.verbose = true;
debug.estimate_sigma = false;
debug.vis_results = true;
%% setup all done
return;
end

