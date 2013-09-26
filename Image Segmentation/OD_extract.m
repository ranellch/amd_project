function disc = OD_extract(I)

%open curvlet enhanced image with circular se size R/4
R = average optic disc size
se = strel('disk', R/8)

%run adaptive corrective function