% call graph-cut executable built from VC, adaptively for win32 and win64 OS

if strcmp(computer, 'PCWIN')
    system(['.\scarSegment\classifyGraphCut\cutInfarct2D.exe .\scarSegment\classifyGraphCut\IM.mat ' num2str(iterNum) ' on']);
    % if you want the energy minimization detail of each slice to be
    % displayed, you can add the final input 'on'
elseif strcmp(computer, 'PCWIN64')
    system(['.\scarSegment\classifyGraphCut\cutInfarct2D_x64.exe .\scarSegment\classifyGraphCut\IM.mat ' num2str(iterNum)]);
else
    error('exeCall:platformChk', 'Current platform not supported.');
end

