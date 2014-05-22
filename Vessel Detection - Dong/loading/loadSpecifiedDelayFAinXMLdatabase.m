function [img, ophth_acquis_context] = loadSpecifiedDelayFAinXMLdatabase(HMS, datafolder)
%[img, ophth_acquis_context] = LOADSPECIFIEDDELAYFAINXMLDATABASE([HMS], datafolder)
%   Detailed documentation will come later.

if ~exist('datafolder', 'var')
    datafolder = uigetdir('', 'Choose data folder:');
end

xmllocator = dir(fullfile(datafolder, '*.xml'));

if isempty(xmllocator)
    error('No XML file found in this folder!');
elseif length(xmllocator)>1
    error('Multiple XML files found in this folder!');
else
    try
        XMLtree = xmlread(fullfile(datafolder, xmllocator.name));
    catch
        error('Failed to read XML file %s.',filename);
    end
end

allImageTagList = XMLtree.getElementsByTagName('Image');
found = 0;
for i = 0:allImageTagList.getLength-1
    thisImageTag = allImageTagList.item(i);
    InjectionTagList = thisImageTag.getElementsByTagName('Injection');
    if ~InjectionTagList.getLength
        continue;
    end
    HMss = str2num( InjectionTagList.item(0).getTextContent); %#ok<ST2NM>
    % truncate to 2 decimal places
    HMss(3) = floor_decimal(HMss(3), 2);
    if isequal(HMS', HMss)
        found = 1;
        break;
    end
end

img = [];
ophth_acquis_context = struct('Width', {}, 'Height', {}, ...
    'ScaleX', {}, 'ScaleY', {}, 'Angle', {}, 'Focus', {}, ...
    'SensorGain', {}, 'NumAve', {}, 'FixationTarget', {});
if found
    % read and store image acquisition parameters
    ophth_acquis_context(1).Width = str2double(thisImageTag.getElementsByTagName('Width').item(0).getTextContent);
    ophth_acquis_context(1).Height = str2double(thisImageTag.getElementsByTagName('Height').item(0).getTextContent);
    ophth_acquis_context(1).ScaleX = str2double(thisImageTag.getElementsByTagName('ScaleX').item(0).getTextContent);
    ophth_acquis_context(1).ScaleY = str2double(thisImageTag.getElementsByTagName('ScaleY').item(0).getTextContent);
    ophth_acquis_context(1).Angle = str2double(thisImageTag.getElementsByTagName('Angle').item(0).getTextContent);
    ophth_acquis_context(1).Focus = str2double(thisImageTag.getElementsByTagName('Focus').item(0).getTextContent);
    ophth_acquis_context(1).SensorGain = str2double(thisImageTag.getElementsByTagName('SensorGain').item(0).getTextContent);
    ophth_acquis_context(1).NumAve = str2double(thisImageTag.getElementsByTagName('NumAve').item(0).getTextContent);
%     ophth_acquis_context(1).FixationTarget = str2double(thisImageTag.getElementsByTagName('FixationTarget').item(0).getTextContent);
    
    % read the image itself
    ExamURL = char( thisImageTag.getElementsByTagName('ExamURL').item(0).getTextContent );
    imgfilename = extractfilename(ExamURL);
    img = imread( fullfile(datafolder, imgfilename) );
    img = im2double(rgb2gray(img));
end

end

function d = floor_decimal(d,n)
d=d*(10^n);
d=floor(d);
d=d/(10^n);
end

function imgfilename = extractfilename(ExamURL)
i=length(ExamURL);

while i>0
    if ExamURL(i) == '\'
        break;
    end
    i = i-1;
end

imgfilename = ExamURL(i+1:end);

end

