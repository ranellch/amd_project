function [m_diff sd_diff] = BlandAltmanPlot(a, b)
%[m_diff sd_diff] = BLANDALTMANPLOT(a, b)
%   Bland-Altman analysis and plot based on the difference (b - a). a and b
%   can be row/col vectors or (even multi-dimension) matrices as long as
%   corresponding measurements to compare are stored at corresponding
%   positions in them.

a = a(:);
b = b(:);

if any(isnan(a)) || any(isnan(b))
    error('BlandAltmanPlot:arginChk', 'Bland-Altman analysis cannot use missing values.');
end

m_value = (b + a) / 2;
diff = b - a;

m_diff = mean(diff);
sd_diff = std(diff, 1);

% scatterplot
xlim = [min(m_value)-2.5 max(m_value)+2.5];
% ylim = [m_diff-3*sd_diff m_diff+3*sd_diff];
ylim = [-max(abs(diff))-2.5 max(abs(diff))+2.5];
figure('Position', [0 300 1440 600]);
scatter(m_value, diff, 100, 'filled'); 
axis([xlim ylim]); set(gca, 'fontsize', 24); hold on;

% draw horizontal lines
line(xlim, [m_diff+1.96*sd_diff m_diff+1.96*sd_diff], 'LineStyle', '--');
line(xlim, [m_diff m_diff], 'LineStyle', '-');
line(xlim, [m_diff-1.96*sd_diff m_diff-1.96*sd_diff], 'LineStyle', '--');
box on; hold off;

end

