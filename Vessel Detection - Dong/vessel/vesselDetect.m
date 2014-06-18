function [vesselmap] = vesselDetect(img_cur, detectionfilter)
%[vesselmap] = VESSELDETECT(img_cur, detectionfilter)
%   此处显示详细说明

vessel_features = vesselFeatures(img_cur, detectionfilter);

label = litekmeans(...
    reorganizeLayeredImgFeatures2RowFeatureVectors(vessel_features).', 2);
vesselmap = false(size(img_cur));
if sum(label==2)*2<numel(label)
    vesselmap(label==2)=true;
else
    vesselmap(label==1)=true;
end

vesselmap = bwmorph(vesselmap, 'fill');
vesselmap = CCFilterRemoveSmallBlobs(vesselmap, 2);

end

