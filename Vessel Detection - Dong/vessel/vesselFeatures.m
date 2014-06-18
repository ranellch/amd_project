function [features] = vesselFeatures(img_cur, type)
%[features] = VESSELFEATURES(img_cur, type)
%   Detailed explanation goes here

features = zero_m_unit_std(img_cur);
if strcmpi(type, 'matching')
    for o = 3:5
        for l = 7:2:11
            vesselResponse = matchingfiltering(img_cur, 15, o, l);
            features = cat(3, features, zero_m_unit_std(vesselResponse));
        end
    end
else
%     [sizey, sizex] = size(img_cur);
%     bigimg = padarray(img_cur, [50 50], 'symmetric');
%     fimg = fft2(bigimg);
%     k0x = 0;
%     for k0y = [3]
%         for a = [.1 .25 .5 1:8]
%             for epsilon = [4]
%                 % Maximum transform over angles.
%                 trans = maxmorlet(fimg, a, epsilon, [k0x k0y], 10);
%                 trans = trans(51:(50+sizey), (51:50+sizex));
%                 % Adding to features
%                 features = cat(3, features, zero_m_unit_std(trans));
% %                 figure; imshow(trans, []);
%             end
%         end
%     end
    %orthogonal line operators
    lineop_len = 15;
    lineop_angcnt = 8;
    lineop_obj = line_operator(lineop_len, lineop_angcnt);
    features_lineop = zeros([size(img_cur) 3]);
    for y = 1:size(img_cur,1)
        for x = 1:size(img_cur,2)
            features_lineop(y,x,:) = lineop_obj.get_fv(img_cur, y,x);
        end
    end
    features = cat(3, features, features_lineop(:,:,1:2));
    
end

end

