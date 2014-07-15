function [ hypo_img ] = find_hypo( pid, eye, time, varargin )
%Returns binary image indicating location of hypofluorescence
resize = 'on';
if length(varargin) == 1
    debug = varargin{1};
elseif isempty(varargin)
    debug = 1;
elseif length(varargin) == 2
    debug = varargin{1};
    resize = varargin{2};
else
    throw(MException('MATLAB:paramAmbiguous','Incorrect number of input arugments'));
end

%Add the path for the useful directories
addpath('..');
addpath(genpath('../Test Set'));
addpath('../intensity normalization');
addpath('../snake');
addpath(genpath('../liblinear-3.18'))
addpath('../Skeleton');
addpath('../Vessel Detection - Chris');



end

