function Smoothed = Smooth_wv(G_image)
[Low, High, Low_i, High_i] = symlets(12);

[Rows, Cols] = size(G_image);
Log_size = floor(log2(max(Rows, Cols)));
New_size = 2^Log_size;
Resized = imresize(G_image, [New_size, New_size], 'bilinear');

Forward = wt2d(Resized, Low, High, Log_size);
Forward_r = -abs(reshape(Forward, 1, New_size*New_size));
Forward_s = sort(Forward_r);
Cutoff = -Forward_s(floor(New_size*New_size*0.1));		% taking 10%
To_take = abs(Forward) > Cutoff;
Forward = Forward .* To_take;

% Forward(New_size/2+1:New_size, :) = ...
%   zeros(size(Forward(New_size/2+1:New_size, :)));
% Forward(:, New_size/2+1:New_size) = ...
%     zeros(size(Forward(:, New_size/2+1:New_size)));
Smoothed = iwt2d(Forward, Low_i, High_i, Log_size, New_size, New_size);
Smoothed = imresize(Smoothed, [Rows, Cols], 'bilinear');
Smoothed = Smoothed .* (Smoothed >= 0);